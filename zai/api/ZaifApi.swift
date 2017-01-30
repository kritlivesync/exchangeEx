//
//  ZaifApi.swift
//  zai
//
//  Created by Kyota Watanabe on 1/1/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift
import SwiftyJSON


fileprivate extension ApiCurrencyPair {
    
    var zaifCurrencyPair: ZaifSwift.CurrencyPair {
        switch self {
        case .BTC_JPY:
            return ZaifSwift.CurrencyPair.BTC_JPY
        }
    }
}

fileprivate extension ZSErrorType {
    var apiError: ApiErrorType {
        switch self {
        case ZSErrorType.INFO_API_NO_PERMISSION:
            return ApiErrorType.NO_PERMISSION
        case ZSErrorType.TRADE_API_NO_PERMISSION:
            return ApiErrorType.NO_PERMISSION
        case ZSErrorType.CONNECTION_ERROR:
            return ApiErrorType.CONNECTION_ERROR
        case ZSErrorType.NONCE_NOT_INCREMENTED:
            return ApiErrorType.NONCE_NOT_INCREMENTED
        case ZSErrorType.INVALID_API_KEY:
            return ApiErrorType.INVALID_API_KEY
        default:
            return ApiErrorType.UNKNOWN_ERROR
        }
    }
}

fileprivate extension Order {
    
    func zaifOrder() -> ZaifSwift.Order? {
        let currencyPair = ApiCurrencyPair(rawValue: self.currencyPair)!
        switch currencyPair {
        case .BTC_JPY:
            let price = self.orderPrice == nil ? nil : Int(self.orderPrice!.doubleValue)
            if self.action == "bid" {
                return ZaifSwift.Trade.Buy.Btc.In.Jpy.createOrder(price, amount: self.orderAmount.doubleValue)
            } else if self.action == "ask" {
                return ZaifSwift.Trade.Sell.Btc.For.Jpy.createOrder(price, amount: self.orderAmount.doubleValue)
            } else {
                return nil
            }
        }
    }
}


protocol ZaiApiDelegate {
    func privateApiCalled(apiName: String)
}


class ZaifApi : Api {
    init(apiKey: String, secretKey: String, nonce: NonceProtocol?=nil) {
        self.api = PrivateApi(apiKey: apiKey, secretKey: secretKey, nonce: nonce)
    }
    
    func getPrice(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Double) -> Void) {
        PublicApi.lastPrice(currencyPair.zaifCurrencyPair) { (err, res) in
            if err != nil {
                print("getPrice: " + err!.message)
                callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), 0.0)
            } else {
                guard let price = res?["last_price"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), 0.0)
                    return
                }
                callback(nil, price)
            }
        }
    }
    
    func getTicker(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Tick) -> Void) {
        PublicApi.ticker(currencyPair.zaifCurrencyPair) { (err, res) in
            if err != nil {
                print("getTicker: " + err!.message)
                callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), Tick())
            } else {
                guard let last = res?["last"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
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
                guard let volume = res?["volume"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let bid = res?["bid"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let ask = res?["ask"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                let tick = Tick(lastPrice: last, highPrice: high, lowPrice: low, vwap: vwap, volume: volume, bid: bid, ask: ask)
                callback(nil, tick)
            }
        }
    }
    
    func getBoard(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Board) -> Void) {
        PublicApi.depth(currencyPair.zaifCurrencyPair) { (err, res) in
            let board = Board()
            if err != nil {
                print("getBoard: " + err!.message)
                callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), board)
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
                    if let quote = ask.array {
                        board.addAsk(price: quote[0].doubleValue, amount: quote[1].doubleValue)
                    }
                }

                for bid in bids {
                    if let quote = bid.array {
                        board.addBid(price: quote[0].doubleValue, amount: quote[1].doubleValue)
                    }
                }
                callback(nil, board)
            }
        }
    }
    
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [String:Double]) -> Void) {
        ZaifApi.queue.async {
            self.api.getInfo2() { (err, res) in
                var balance = [String:Double]()
                if err != nil {
                    print("getBalance: " + err!.message)
                    callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), balance)
                } else {
                    guard let deposits = res?["return"]["deposit"].dictionary else {
                        callback(ApiError(errorType: .UNKNOWN_ERROR), balance)
                        return
                    }
                    for currency in currencies {
                        if let deposit = deposits[currency.rawValue]?.double {
                            balance[currency.rawValue] = deposit
                        }
                    }
                    callback(nil, balance)
                }
                self.delegate?.privateApiCalled(apiName: "getBalance")
            }
        }
    }
    
    func getActiveOrders(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [String:ActiveOrder]) -> Void) {
        ZaifApi.queue.async {
            self.api.activeOrders(currencyPair.zaifCurrencyPair) { (err, res) in
                var activeOrders = [String:ActiveOrder]()
                if err != nil {
                    print("getActiveOrders: " + err!.message)
                    callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), activeOrders)
                    return
                }
                
                guard let result = res?["success"].int else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), activeOrders)
                    return
                }
                if result != 1 {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), activeOrders)
                    return
                }
                guard let orders = res?["return"].dictionary else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), activeOrders)
                    return
                }
                
                for (id, order) in orders {
                    let action = order["action"].stringValue
                    let price = order["price"].doubleValue
                    let amount = order["amount"].doubleValue
                    let timestamp = order["timestamp"].int64Value
                    let activeOrder = ActiveOrder(id: id, action: action, currencyPair: currencyPair, price: price, amount: amount, timestamp: timestamp)
                    activeOrders[id] = activeOrder
                }
                callback(nil, activeOrders)
                self.delegate?.privateApiCalled(apiName: "activeOrders")
            }
        }
    }
    
    func getTrades(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [Trade]) -> Void) {
        PublicApi.trades(currencyPair.zaifCurrencyPair) { (err, res) in
            var trades = [Trade]()
            if err != nil {
                print("getTrades: " + err!.message)
                callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), trades)
            } else {
                guard let tradeArray = res?.array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), trades)
                    return
                }
                for tradeData in tradeArray {
                    guard let data = tradeData.dictionary else {
                        continue
                    }
                    let trade = Trade(
                        id: data["tid"]!.stringValue,
                        price: data["price"]!.doubleValue,
                        amount: data["amount"]!.doubleValue,
                        currencyPair: data["currency_pair"]!.stringValue,
                        action: data["trade_type"]!.stringValue,
                        timestamp: data["date"]!.int64Value)
                    trades.append(trade)
                }
                callback(nil, trades)
            }
        }
    }
    
    func trade(order: Order, retryCount: Int, callback: @escaping (ApiError?, String, Double, Double) -> Void) {
        guard let zaifOrder = order.zaifOrder() else {
            callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
            return
        }
        
        ZaifApi.queue.async {
            self.api.trade(zaifOrder, validate: false) { (err, res) in
                if let e = err {
                    if 0 < retryCount {
                        print("trade: retry")
                        self.trade(order: order, retryCount: retryCount - 1, callback: callback)
                        return
                    } else {
                        print("trade: " + e.message)
                        callback(ApiError(errorType: e.errorType.apiError, message: e.message), "", 0.0, 0.0)
                        return
                    }
                }
                guard let result = res?["success"].int else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
                    return
                }
                if result != 1 {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
                    return
                }
                guard let ordered = res?["return"].dictionary else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), "", 0.0, 0.0)
                    return
                }
                let orderId = ordered["order_id"]!.stringValue
                let orderedPrice = ordered["order_price"]!.doubleValue
                
                callback(nil, orderId, orderedPrice, Double(zaifOrder.amountString)!)
                self.delegate?.privateApiCalled(apiName: "trade")
            }
        }
    }
    
    func cancelOrder(order: ActiveOrder, retryCount: Int, callback: @escaping (_ err: ApiError?) -> Void) {
        ZaifApi.queue.async {
            self.api.cancelOrder(Int(order.id)!) { (err, res) in
                if let e = err {
                    if 0 < retryCount {
                        print("cancelOrder: retry")
                        self.cancelOrder(order: order, retryCount: retryCount - 1, callback: callback)
                        return
                    } else {
                        print("cancelOrder: " + e.message)
                        callback(ApiError(errorType: e.errorType.apiError, message: e.message))
                        return
                    }
                }
                guard let result = res?["success"].int else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR))
                    return
                }
                if result != 1 {
                    callback(ApiError(errorType: .UNKNOWN_ERROR))
                    return
                }
                callback(nil)
                self.delegate?.privateApiCalled(apiName: "cancelOrder")
            }
        }
    }
    
    func validateApi(callback: @escaping (_ err: ApiError?) -> Void) {
        ZaifApi.queue.async {
            self.api.searchValidNonce(count: 60, step: 100) { err in
                if err != nil {
                    self.validatePermission() { err in
                        callback(ApiError(errorType: err!.errorType, message: err!.message))
                    }
                } else {
                    self.validatePermission(callback: callback)
                }
                self.delegate?.privateApiCalled(apiName: "validateApi")
            }
        }
    }

    func currencyPairs() -> [ApiCurrencyPair] {
        return [ApiCurrencyPair.BTC_JPY]
    }
    
    func currencies() -> [ApiCurrency] {
        return [ApiCurrency.JPY]
    }
    
    func orderUnit(currencyPair: ApiCurrencyPair) -> Double {
        return currencyPair.zaifCurrencyPair.orderUnit
    }
    
    fileprivate func validatePermission(callback: @escaping (_ err: ApiError?) -> Void) {
        ZaifApi.queue.async {
            self.api.getInfo2() { (err, res) in
                if err != nil {
                    callback(ApiError(errorType: err!.errorType.apiError, message: err!.message))
                    return
                }
                guard let result = res?["success"].int else {
                    callback(ApiError(errorType: .NO_PERMISSION))
                    return
                }
                if result != 1 {
                    callback(ApiError(errorType: .NO_PERMISSION))
                    return
                }
                guard let rights = res?["return"]["rights"] else {
                    callback(ApiError(errorType: .NO_PERMISSION))
                    return
                }
                if rights["info"].intValue != 1 {
                    callback(ApiError(errorType: .NO_PERMISSION))
                    return
                }
                if rights["trade"].intValue != 1 {
                    callback(ApiError(errorType: .NO_PERMISSION))
                    return
                }
                callback(nil)
                self.delegate?.privateApiCalled(apiName: "validatePermission")
            }
        }
    }
    
    var rawApi: Any { get { return self.api } }
    
    static let queue = DispatchQueue(label: "zaifapiqueue")
    let api: PrivateApi
    var delegate: ZaiApiDelegate?
}
