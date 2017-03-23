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
        case ZSErrorType.INSUFFICIENT_FUNDS:
            return ApiErrorType.INSUFFICIENT_FUNDS
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
    
    func getBoard(currencyPair: ApiCurrencyPair, maxSize: Int, callback: @escaping (ApiError?, Board) -> Void) {
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
                
                board.sort()
                board.trunc(size: maxSize)
                
                callback(nil, board)
            }
        }
    }
    
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [Balance]) -> Void) {
        ZaifApi.queue.async {
            self.api.getInfo2() { (err, res) in
                var balances = [Balance]()
                if err != nil {
                    print("getBalance: " + err!.message)
                    callback(ApiError(errorType: err!.errorType.apiError, message: err!.message), balances)
                } else {
                    guard let deposits = res?["return"]["deposit"].dictionary else {
                        callback(ApiError(errorType: .UNKNOWN_ERROR), balances)
                        return
                    }
                    for currency in currencies {
                        if let deposit = deposits[currency.rawValue]?.double {
                            let balance = Balance(currency: currency, amount: deposit, available: deposit)
                            balances.append(balance)
                        }
                    }
                    callback(nil, balances)
                }
                self.delegate?.privateApiCalled(apiName: "getBalance")
            }
        }
    }
    
    func getCommission(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Double) -> Void) {
        ZaifApi.queue.async {
            callback(nil, -0.01)
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
        
        if zaifOrder.amount < zaifOrder.currencyPair.orderUnit {
            callback(ApiError(errorType: .INVALID_ORDER_AMOUNT), "", 0.0, 0.0)
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
    
    func isPromised(order: Order, callback: @escaping (_ err: ApiError?, _ proisedOrder: PromisedOrder?) -> Void) {
        if order.isInvalid {
            callback(ApiError(errorType: .INVALID_ORDER), nil)
            return
        }
        if order.orderId == nil {
            callback(ApiError(errorType: .ORDER_NOT_ACTIVE), nil)
            return
        }
        
        self.getActiveOrders(currencyPair: ApiCurrencyPair(rawValue: order.currencyPair)!) { (err, activeOrders) in
            if err != nil {
                callback(err, nil)
                return
            }
            if let activeOrder = activeOrders[order.orderId!] {
                guard let promisedOrder = self.extractPartiallyPromisedOrder(activeOrder: activeOrder, order: order) else {
                    return
                }
                callback(nil, promisedOrder)
            } else {
                if order.isActive == false { // safety
                    callback(ApiError(errorType: .ORDER_NOT_ACTIVE), nil)
                    return
                }
                var newlyPromisedAmount = order.orderAmount.doubleValue
                if let amount = order.promisedAmount {
                    newlyPromisedAmount = order.orderAmount.doubleValue - amount.doubleValue
                }
                let promisedOrder = PromisedOrder(orderId: order.orderId!, currencyPair: order.currencyPair, action: order.action, price: order.orderPrice!.doubleValue, promisedAmount: order.orderAmount.doubleValue, newlyPromisedAmount: newlyPromisedAmount, timestamp: Int64(Date().timeIntervalSince1970), isPartially: false)
                callback(nil, promisedOrder)
            }
        }
    }
    
    func createBoardStream(currencyPair: ApiCurrencyPair, maxSize: Int, onOpen: @escaping (ApiError?) -> Void, onClose: @escaping (ApiError?) -> Void, onError: @escaping (ApiError?) -> Void, onData: @escaping (ApiError?, Board) -> Void) -> StreamApi {
        
        let stream = ZaifStreamApi(currencyPair: currencyPair, onOpen: onOpen, onClose: onClose, onError: onError) { (err, data) in
            let board = Board()
            if err != nil {
                print("getBoard: " + err!.message)
                onData(ApiError(errorType: err!.errorType, message: err!.message), board)
            } else {
                guard let asks = data?["asks"].array else {
                    onData(ApiError(errorType: .UNKNOWN_ERROR), board)
                    return
                }
                guard let bids = data?["bids"].array else {
                    onData(ApiError(errorType: .UNKNOWN_ERROR), board)
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
                
                board.sort()
                board.trunc(size: maxSize)
                
                onData(nil, board)
            }
        }
        
        return stream
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
    
    func decimalDigit(currencyPair: ApiCurrencyPair) -> Int {
        switch currencyPair {
        case .BTC_JPY:
            return 4
        }
    }
    
    fileprivate func extractPartiallyPromisedOrder(activeOrder: ActiveOrder, order: Order) -> PromisedOrder? {
        if activeOrder.timestamp <= order.promisedTime!.int64Value {
            return nil
        }
        let promisedAmount = order.orderAmount.doubleValue - activeOrder.amount
        let orderUnit = self.orderUnit(currencyPair: ApiCurrencyPair(rawValue: order.currencyPair)!)
        if promisedAmount < orderUnit {
            return nil
        }
        let newlyPromisedAmount = promisedAmount - order.promisedAmount!.doubleValue
        if newlyPromisedAmount < orderUnit {
            return nil
        }
        return PromisedOrder(orderId: activeOrder.id, currencyPair: activeOrder.currencyPair.rawValue, action: activeOrder.action, price: activeOrder.price, promisedAmount: promisedAmount, newlyPromisedAmount: newlyPromisedAmount, timestamp: activeOrder.timestamp, isPartially: true)
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


class ZaifStreamApi : StreamApi {
    init(currencyPair: ApiCurrencyPair, onOpen: @escaping (ApiError?) -> Void, onClose: @escaping (ApiError?) -> Void, onError: @escaping (ApiError?) -> Void, onData: @escaping (ApiError?, JSON?) -> Void) {
        
        self.onOpenCallback = onOpen
        self.onCloseCallback = onClose
        self.onErrorCallback = onError
        self.onDataCallback = onData
        self.stream = nil
        
        self.stream = StreamingApi.stream(currencyPair.zaifCurrencyPair, openCallback: self.onOpen)
        
        self.stream.onClose(callback: self.onClose)
        
        self.stream.onError(callback: self.onError)
        
        self.stream.onData() { (_ err: ZSError?, _ res: JSON?) in
            if let e = err {
                onData(ApiError(errorType: (e.errorType.apiError)), nil)
            } else {
                onData(nil, res)
            }
        }
    }
    
    func open() {
        self.stream.open(callback: self.onOpen)
    }
    
    func close() {
        self.stream.close(callback: self.onClose)
    }
    
    var rawStream: Any {
        return self.stream
    }
    
    fileprivate func onOpen(_ err: ZSError?, _ res: JSON?) {
        if let e = err {
            self.onOpenCallback(ApiError(errorType: (e.errorType.apiError)))
        } else {
            self.onOpenCallback(ApiError())
        }
    }
    
    fileprivate func onClose(_ err: ZSError?, _ res: JSON?) {
        if let e = err {
            self.onCloseCallback(ApiError(errorType: (e.errorType.apiError)))
        } else {
            self.onCloseCallback(ApiError())
        }
    }
    
    fileprivate func onError(_ err: ZSError?, _ res: JSON?) {
        if let e = err {
            self.onErrorCallback(ApiError(errorType: (e.errorType.apiError)))
        } else {
            self.onErrorCallback(ApiError())
        }
    }
    
    var stream: ZaifSwift.Stream!
    let onOpenCallback: (ApiError?) -> Void
    let onCloseCallback: (ApiError?) -> Void
    let onErrorCallback: (ApiError?) -> Void
    let onDataCallback: (ApiError?, JSON?) -> Void
}
