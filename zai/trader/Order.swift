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
    init?(currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        self.id = -1
        self.status = .WAITING
        if self.id >= 0 {
            // assume that this order is being constracted by existing active order
            self.status = .ACTIVE
        }
        self.promisedTime = 0
        self.promisedPrice = 0.0
        self.privateApi = api
        
        self.zaifOrder = nil
        let order = self.createOrder(currencyPair, price: price, amount: amount)
        if order == nil {
            return nil
        }
        self.zaifOrder = order
    }
    
    internal func excute(cb: (ZaiError?, Int) -> Void) {
        if self.status != .WAITING {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order already active"), -1)
            return
        }

        self.privateApi.trade(self.zaifOrder) { (err, res) in
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

    internal func waitForPromise(cb: (ZaiError?, Bool) -> Void) {
        if self.status != .ACTIVE {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not excuted"), false)
            return
        }
        
        self.privateApi.activeOrders(self.zaifOrder.currencyPair) { (err, res) in
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
                            self.status = .PROMISED
                            self.promisedTime = Int64(NSDate().timeIntervalSince1970)
                            cb(nil, true)
                        } else {
                            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not active"), false)
                        }
                    }
                }
            }
        }
    }
    
    internal func cancel(cb: (ZaiError?) -> Void) {
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
    
    private func createOrder(currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        return nil
    }
    
    internal var orderId: Int {
        get {
            return self.id
        }
    }
    
    internal var currencyPair: CurrencyPair {
        get {
            return self.zaifOrder.currencyPair
        }
    }
    
    internal var action: OrderAction {
        get {
            return self.zaifOrder.action
        }
    }
    
    internal var price: Double {
        get {
            if self.isPromised {
                return self.promisedPrice
            } else {
                if let p = self.zaifOrder.price {
                    return p
                } else {
                    return 0.0 // 成行き注文の約定前
                }
            }
        }
    }
    
    internal var amount: Double {
        get {
            return self.zaifOrder.amount
        }
    }
    
    internal var isPromised: Bool {
        get {
            return self.status == .PROMISED
        }
    }
    
    private var id: Int // Zaif order_id
    internal let privateApi: PrivateApi
    private var zaifOrder: ZaifSwift.Order!
    internal var status: OrderState
    internal var promisedTime: Int64
    internal var promisedPrice: Double
}

internal class BuyOrder : Order {
    override init?(currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        super.init(currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override private func createOrder(currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        switch currencyPair {
        case .BTC_JPY:
            return Trade.Buy.Btc.In.Jpy.createOrder(price == nil ? nil : Int(price!), amount: amount)
        case .MONA_JPY:
            return Trade.Buy.Mona.In.Jpy.createOrder(price, amount: Int(amount))
        default:
            return nil
        }
    }
}

internal class SellOrder : Order {
    override init?(currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        super.init(currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override private func createOrder(currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        switch currencyPair {
        case .BTC_JPY:
            return Trade.Sell.Btc.For.Jpy.createOrder(price == nil ? nil : Int(price!), amount: amount)
        case .MONA_JPY:
            return Trade.Sell.Mona.For.Jpy.createOrder(price, amount: Int(amount))
        default:
            return nil
        }
    }
}