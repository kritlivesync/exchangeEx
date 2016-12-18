//
//  Order.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON
import ZaifSwift


internal enum OrderState {
    case WAITING
    case ORDERING
    case PARTIALLY_PROMISED
    case PROMISED
    case CANCELING
    case CANCELLED
    case INVALID
    
    var isActive: Bool {
        get {
            switch self {
            case .ORDERING, .PARTIALLY_PROMISED:
                return true
            case .WAITING, .PROMISED, .CANCELING, .CANCELLED, .INVALID:
                return false
            default:
                return false
            }
        }
    }
}

struct PromisedOrder {
    let promisedAmount: Double
    let newlyPromisedAmount: Double
    let timestamp: Int64
}

protocol OrderDelegate : NSObjectProtocol {
    func orderPromised(order: Order, price: Double, amount: Double)
    func orderPartiallyPromised(order: Order, price: Double, amount: Double)
    func orderCancelled(order: Order)
}

internal class Order : Monitorable {
    init?(id: Int?, currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        self.id = id ?? -1
        self.status = .WAITING
        if self.id >= 0 {
            // assume that this order is being constracted by existing active order
            self.status = .ORDERING
        }
        self.promisedTime = 0
        self.promisedPrice = 0.0
        self.promisedAmount = 0.0
        self.privateApi = api
        self.orderPrice = price
        self.zaifOrder = nil
        super.init()
        
        let order = self.createOrder(currencyPair, price: price, amount: amount)
        if order == nil {
            return nil
        }
        self.zaifOrder = order
    }
    
    internal func excute(_ cb: @escaping (ZaiError?, Int) -> Void) {
        if self.status != .WAITING || self.id >= 0 {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order already active"), -1)
            return
        }

        self.privateApi.trade(self.zaifOrder, validate: false) { (err, res) in
            if let e = err {
                self.status = .INVALID
                cb(ZaiError(errorType: .INVALID_ORDER, message: e.message), -1)
            } else {
                if res!["success"].intValue != 1 {
                    self.status = .INVALID
                    cb(ZaiError(errorType: .INVALID_ORDER), -1)
                } else {
                    self.id = res!["return"]["order_id"].intValue
                    self.orderPrice = res!["return"]["order_price"].doubleValue
                    self.status = .ORDERING
                    cb(nil, self.id)
                }
            }
        }
    }
    
    internal func cancel(_ cb: @escaping (ZaiError?) -> Void) {
        if self.status.isActive == false {
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
    
    override func monitor() {
        if self.status.isActive == false {
            return
        }
        if self.delegate == nil {
            return
        }
        self.privateApi.activeOrders(self.zaifOrder.currencyPair) { (err, res) in
            if err != nil {
                return
            }
            if res!["success"].intValue != 1 {
                return
            }
            
            let idExists = res?["return"].dictionaryValue.keys.contains(self.id.description)
            if idExists == false {
                if self.isActive == false { // safety
                    return
                }
                self.status = .PROMISED
                self.promisedTime = Int64(NSDate().timeIntervalSince1970)
                self.promisedPrice = self.orderPrice!
                let newlyPromisedAmount = self.zaifOrder.amount - self.promisedAmount
                self.promisedAmount = self.zaifOrder.amount
                self.delegate?.orderPromised(order: self, price: self.promisedPrice, amount: newlyPromisedAmount)
            } else {
                let promisedOrder = self.extractPromisedOrder(data: res)
                if promisedOrder == nil {
                    return
                }
                self.promisedAmount = promisedOrder!.promisedAmount
                self.promisedTime = promisedOrder!.timestamp
                self.delegate?.orderPartiallyPromised(order: self, price: self.orderPrice!, amount: promisedOrder!.newlyPromisedAmount)
            }
        }
    }
    
    fileprivate func extractPromisedOrder(data: JSON?) -> PromisedOrder? {
        let order = data?["return"].dictionaryValue[self.id.description]?.dictionaryValue
        let timestamp = order?["timestamp"]?.int64Value
        if timestamp == nil || timestamp! <= self.promisedTime {
            return nil
        }
        let promisedAmount = self.zaifOrder.amount - (order?["amount"]?.doubleValue)!
        if promisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        let newlyPromisedAmount = promisedAmount - self.promisedAmount
        if newlyPromisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        return PromisedOrder(promisedAmount: promisedAmount, newlyPromisedAmount: newlyPromisedAmount, timestamp: timestamp!)
    }
    
    fileprivate func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
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
                if let p = self.orderPrice {
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
    
    internal var isActive: Bool {
        get {
            return self.status.isActive
        }
    }
    
    internal var id: Int // Zaif order_id
    internal let privateApi: PrivateApi
    fileprivate var zaifOrder: ZaifSwift.Order!
    internal var status: OrderState
    internal var promisedTime: Int64
    internal var promisedPrice: Double
    internal var promisedAmount: Double
    internal var orderPrice: Double? = nil
    var delegate: OrderDelegate?
}

internal class BuyOrder : Order {
    override init?(id: Int?, currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        super.init(id: id, currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override fileprivate func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
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
    override init?(id: Int?, currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
        super.init(id: id, currencyPair: currencyPair, price: price, amount: amount, api: api)
    }
    
    override fileprivate func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
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
