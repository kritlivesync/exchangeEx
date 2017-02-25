//
//  bitFlyerApi.swift
//  zai
//
//  Created by 渡部郷太 on 2/14/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON
import bFSwift


fileprivate extension ApiCurrencyPair {
    
    var bFCurrencyPair: bFSwift.ProductCode {
        switch self {
        case .BTC_JPY:
            return bFSwift.ProductCode.btcJpy
        }
    }
}

fileprivate extension ApiCurrency {
    var bFCurrency: String {
        switch self {
        case .JPY:
            return "JPY"
        case .BTC:
            return "BTC"
        }
    }
}

fileprivate extension Side {
    var action: String {
        switch self {
        case .buy:
            return "bid"
        case .sell:
            return "ask"
        }
    }
}

fileprivate extension Order {
    
    func bfOrder() -> bFSwift.Order? {
        let currencyPair = ApiCurrencyPair(rawValue: self.currencyPair)!
        switch currencyPair {
        case .BTC_JPY:
            let price = self.orderPrice == nil ? nil : Int(self.orderPrice!.doubleValue)
            if self.action == "bid" {
                return BuyBtcInJpyOrder(price: price, size: self.orderAmount.doubleValue)
            } else if self.action == "ask" {
                return SellBtcForJpyOrder(price: price, size: self.orderAmount.doubleValue)
            } else {
                return nil
            }
        }
    }
}


fileprivate extension BFErrorCode {
    var apiError: ApiErrorType {
        switch self {
        //case ZSErrorType.INFO_API_NO_PERMISSION:
        //    return ApiErrorType.NO_PERMISSION
        //case ZSErrorType.TRADE_API_NO_PERMISSION:
        //    return ApiErrorType.NO_PERMISSION
        case BFErrorCode.connectionError:
            return ApiErrorType.CONNECTION_ERROR
        case BFErrorCode.invalidOrderSize:
            return ApiErrorType.INVALID_ORDER_AMOUNT
        //case ZSErrorType.NONCE_NOT_INCREMENTED:
        //    return ApiErrorType.NONCE_NOT_INCREMENTED
        //case ZSErrorType.INVALID_API_KEY:
        //    return ApiErrorType.INVALID_API_KEY
        default:
            return ApiErrorType.UNKNOWN_ERROR
        }
    }
}


class bitFlyerApi : Api {
    
    init(apiKey: String, secretKey: String) {
        self.api = PrivateApi(apiKey: apiKey, secretKey: secretKey)
    }
    
    func getPrice(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Double) -> Void) {
        getTicker(currencyPair: currencyPair) { (err, tick) in
            callback(err, tick.lastPrice)
        }
    }
    
    func getTicker(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Tick) -> Void) {
        PublicApi.getTicker(productCode: currencyPair.bFCurrencyPair) { (err, res) in
            if err != nil {
                print("getTicker: " + err!.message)
                callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), Tick())
            } else {
                guard let last = res?["ltp"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                /*
                guard let high = res?["high"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let low = res?["low"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let vwap = res?["vwap"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                */
                guard let volume = res?["volume"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let bid = res?["best_bid"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let ask = res?["best_ask"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                let tick = Tick(lastPrice: last, highPrice: 0.0, lowPrice: 0.0, vwap: 0.0, volume: volume, bid: bid, ask: ask)
                callback(nil, tick)
            }
        }
    }
    
    func getBoard(currencyPair: ApiCurrencyPair, maxSize: Int, callback: @escaping (ApiError?, Board) -> Void) {
        PublicApi.getBoard(productCode: currencyPair.bFCurrencyPair) { (err, res) in
            let board = Board()
            if err != nil {
                print("getBoard: " + err!.message)
                callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), board)
            } else {
                guard let asks = res?["asks"].array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), board)
                    return
                }
                guard let bids = res?["bids"].array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), board)
                    return
                }
                
                for ask in asks {
                    if let quote = ask.dictionary {
                        board.addAsk(price: quote["price"]!.doubleValue, amount: quote["size"]!.doubleValue)
                    }
                }
                
                for bid in bids {
                    if let quote = bid.dictionary {
                        board.addBid(price: quote["price"]!.doubleValue, amount: quote["size"]!.doubleValue)
                    }
                }
                
                board.sort()
                board.trunc(size: maxSize)
                
                callback(nil, board)
            }
        }
    }
    
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [String:Double]) -> Void) {
        bitFlyerApi.queue.async {
            self.api.getBalance() { (err, res) in
                var balance = [String:Double]()
                if err != nil {
                    print("getBalance: " + err!.message)
                    callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), balance)
                } else {
                    var deposits = [String:Double]()
                    for balance in res!.arrayValue {
                        let cur = balance["currency_code"].stringValue
                        let amount = balance["amount"].doubleValue
                        deposits[cur] = amount
                    }
                    
                    for currency in currencies {
                        balance[currency.rawValue] = 0.0
                        if let amount = deposits[currency.bFCurrency] {
                            balance[currency.rawValue] = amount
                        }
                    }
                    callback(nil, balance)
                }
            }
        }
    }
    
    func getActiveOrders(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [String:ActiveOrder]) -> Void) {
        bitFlyerApi.queue.async {
            self.api.getChildOrders(productCode: currencyPair.bFCurrencyPair, childOrderState: ChildOrderState.active) { (err, res) in
                var activeOrders = [String:ActiveOrder]()
                if err != nil {
                    print("getActiveOrders: " + err!.message)
                    callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), activeOrders)
                    return
                }

                guard let orders = res?.array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), activeOrders)
                    return
                }
                
                for order in orders {
                    let id = order["child_order_id"].stringValue
                    let action = Side(rawValue: order["side"].stringValue)!.action
                    let price = order["price"].doubleValue
                    let amount = order["size"].doubleValue - order["executed_size"].doubleValue
                    let activeOrder = ActiveOrder(id: id, action: action, currencyPair: currencyPair, price: price, amount: amount, timestamp: timestamp())
                    activeOrders[id] = activeOrder
                }
                callback(nil, activeOrders)
            }
        }
    }
    
    func getTrades(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [Trade]) -> Void) {
        PublicApi.getExcutions(productCode: currencyPair.bFCurrencyPair, count: 500) { (err, res) in
            var trades = [Trade]()
            if err != nil {
                print("getTrades: " + err!.message)
                callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), trades)
            } else {
                guard let tradeArray = res?.array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), trades)
                    return
                }
                for tradeData in tradeArray {
                    guard let data = tradeData.dictionary else {
                        continue
                    }
                    let date = data["exec_date"]!.stringValue
                    let trade = Trade(
                        id: data["id"]!.stringValue,
                        price: data["price"]!.doubleValue,
                        amount: data["size"]!.doubleValue,
                        currencyPair: currencyPair.rawValue,
                        action: Side(rawValue: data["side"]!.stringValue)!.action,
                        timestamp: timestamp(date: date.components(separatedBy: ".")[0]))
                    trades.append(trade)
                }
                callback(nil, trades)
            }
        }
    }
    
    func trade(order: Order, retryCount: Int, callback: @escaping (_ err: ApiError?, _ orderId: String, _ orderedPrice: Double, _ orderedAmount: Double) -> Void) {
        guard let bfOrder = order.bfOrder() else {
            callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
            return
        }
        
        if bfOrder.size < bfOrder.productCode.orderUnit {
            callback(ApiError(errorType: .INVALID_ORDER_AMOUNT), "", 0.0, 0.0)
            return
        }
        
        bitFlyerApi.queue.async {
            self.api.sendChildOrder(order: bfOrder) { (err, res) in
                if let e = err {
                    if 0 < retryCount {
                        print("trade: retry")
                        self.trade(order: order, retryCount: retryCount - 1, callback: callback)
                        return
                    } else {
                        print("trade: " + e.message)
                        callback(ApiError(errorType: e.errorCode.apiError, message: e.message), "", 0.0, 0.0)
                        return
                    }
                }

                guard let orderId = res?["child_order_acceptance_id"].string else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
                    return
                }
                let price = (bfOrder.price != nil) ? bfOrder.price! : 0.0
                callback(nil, orderId, price, bfOrder.size)
            }
        }
    }
    
    func cancelOrder(order: ActiveOrder, retryCount: Int, callback: @escaping (_ err: ApiError?) -> Void) {
        callback(ApiError())
    }
    
    func createBoardStream(currencyPair: ApiCurrencyPair, maxSize: Int, onOpen: @escaping (ApiError?) -> Void, onClose: @escaping (ApiError?) -> Void, onError: @escaping (ApiError?) -> Void, onData: @escaping (ApiError?, Board) -> Void) -> StreamApi {
        
        return BitFlyerStreamApi()
    }
    
    func validateApi(callback: @escaping (_ err: ApiError?) -> Void) {
        bitFlyerApi.queue.async {
            let permissions = [
                PermissionType.getpermissions,
                PermissionType.getbalance,
                PermissionType.sendchildorder,
                PermissionType.cancelchildorder,
                PermissionType.cancelallchildorders,
                PermissionType.getchildorders,
                PermissionType.getexecutions,
            ]
            self.api.hasPermissions(permissions: permissions) { err, noPermissions in
                if noPermissions.count > 0 {
                    callback(ApiError(errorType: .NO_PERMISSION))
                } else {
                    callback(nil)
                }
                
            }
        }
    }
    
    func currencyPairs() -> [ApiCurrencyPair] {
        return [ApiCurrencyPair.BTC_JPY]
    }
    
    func currencies() -> [ApiCurrency] {
        return [ApiCurrency.JPY, ApiCurrency.BTC]
    }
    
    func orderUnit(currencyPair: ApiCurrencyPair) -> Double {
        return currencyPair.bFCurrencyPair.orderUnit
    }
    
    var rawApi: Any {
        return self.api
    }
    
    static let queue = DispatchQueue(label: "bitflyerapiqueue")
    let api: bFSwift.PrivateApi
}


class BitFlyerStreamApi : StreamApi {
    func open() {
        
    }
    
    func close() {
        
    }
    
    var rawStream: Any {
        return 1
    }
}
