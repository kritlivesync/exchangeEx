//
//  Order.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal enum OrderState {
    case WAITING
    case ACTIVE
    case PROMISED
    case CANCELLED
    case INVALID
}

internal class Order {
    init(id: Int = -1, currencyPair: CurrencyPair, price: Double, amount: Double, api: PrivateApi) {
        self.id = id
        self.currencyPair = currencyPair
        self.price = price
        self.amount = amount
        self.status = .WAITING
        if self.id >= 0 {
            // assume that this order is being constracted by existing active order
            self.status = .ACTIVE
        }
        self.privateApi = api
    }
    
    func excute(cb: ((ZaiError?, Int) -> Void)) {
        if self.status != .WAITING {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order already active"), -1)
            return
        }
        
        let order = self.createOrder()
        if order == nil {
            // todo async
            self.status = .INVALID
            cb(ZaiError(errorType: .INVALID_ORDER, message: "invalide currency pair"), -1)
            return
        }
        
        self.privateApi.trade(order!) { (err, res) in
            if let e = err {
                self.status = .INVALID
                cb(ZaiError(errorType: .INVALID_ORDER, message: e.message), -1)
            } else {
                if res!["success"].intValue != 1 {
                    self.status = .INVALID
                    cb(ZaiError(errorType: .INVALID_ORDER), -1)
                } else {
                    self.id = res!["return"]["order_id"].intValue
                    self.status = .ACTIVE
                    cb(nil, self.id)
                }
            }
        }
    }
    
    internal func waitForPromise(cb: ((ZaiError?, Bool) -> Void)) {
        if self.status != .ACTIVE {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not excuted"), false)
            return
        }
        
        self.privateApi.activeOrders(self.currencyPair) { (err, res) in
            if let e = err {
                self.status = .INVALID
                cb(ZaiError(errorType: .INVALID_ORDER, message: e.message), false)
            } else {
                if res!["success"].intValue != 1 {
                    self.status = .INVALID
                    cb(ZaiError(errorType: .INVALID_ORDER), false)
                } else {
                    let idExists = res!["return"].dictionaryValue.keys.contains(self.id.description)
                    if idExists {
                        self.waitForPromise(cb)
                    } else {
                        if self.status == .ACTIVE { // double check
                            cb(nil, true)
                        } else {
                            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not active"), false)
                        }
                    }
                    
                }
            }
        }
    }
    
    internal func cancel(cb: ((ZaiError?) -> Void)) {
        if self.status != .ACTIVE {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not excuted"))
            return
        }
        self.privateApi.cancelOrder(self.id) { (err, res) in
            if res!["success"].intValue != 1 {
                self.status = .INVALID
                cb(ZaiError(errorType: .INVALID_ORDER))
            } else {
                self.status = .CANCELLED
                cb(nil)
            }
        }
    }
    
    private func createOrder() -> ZaifSwift.Order? {
        return nil
    }
    
    private var id: Int
    internal let privateApi: PrivateApi
    internal let currencyPair: CurrencyPair
    internal let price: Double
    internal let amount: Double
    internal var status: OrderState
}

internal class BuyOrder : Order {
    override init(id: Int = -1, currencyPair: CurrencyPair, price: Double, amount: Double, api: PrivateApi) {
        super.init(id: id, currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override private func createOrder() -> ZaifSwift.Order? {
        switch self.currencyPair {
        case .BTC_JPY:
            return Trade.Buy.Btc.In.Jpy.createOrder(Int(self.price), amount: self.amount)
        case .MONA_JPY:
            return Trade.Buy.Mona.In.Jpy.createOrder(self.price, amount: Int(self.amount))
        default:
            return nil
        }
    }
}

internal class SellOrder : Order {
    override init(id: Int = -1, currencyPair: CurrencyPair, price: Double, amount: Double, api: PrivateApi) {
        super.init(id: id, currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override private func createOrder() -> ZaifSwift.Order? {
        switch self.currencyPair {
        case .BTC_JPY:
            return Trade.Sell.Btc.For.Jpy.createOrder(Int(self.price), amount: self.amount)
        case .MONA_JPY:
            return Trade.Sell.Mona.For.Jpy.createOrder(self.price, amount: Int(self.amount))
        default:
            return nil
        }
    }
}