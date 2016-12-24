//
//  Order+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 12/19/16.
//
//

import Foundation
import CoreData

import SwiftyJSON
import ZaifSwift


internal enum OrderState : Int {
    case WAITING=0
    case ORDERING=1
    case PARTIALLY_PROMISED=2
    case PROMISED=3
    case CANCELING=4
    case CANCELLED=5
    case INVALID=6
    
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


@objc(Order)
public class Order: NSManagedObject {
    
    internal func excute(_ cb: @escaping (ZaiError?, String?) -> Void) {
        if self.status.intValue != OrderState.WAITING.rawValue || self.orderId != nil {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order already active"), nil)
            return
        }
        
        self.privateApi?.trade(self.zaifOrder, validate: false) { (err, res) in
            if let e = err {
                self.status = NSNumber(value: OrderState.INVALID.rawValue)
                cb(ZaiError(errorType: .INVALID_ORDER, message: e.message), nil)
            } else {
                if res!["success"].intValue != 1 {
                    self.status = NSNumber(value: OrderState.INVALID.rawValue)
                    cb(ZaiError(errorType: .INVALID_ORDER), nil)
                } else {
                    self.orderId = res!["return"]["order_id"].stringValue
                    self.orderPrice = res!["return"]["order_price"].doubleValue as NSNumber?
                    self.status = NSNumber(value: OrderState.ORDERING.rawValue)
                    cb(nil, self.orderId!)
                }
            }
        }
    }
    
    internal func cancel(_ cb: @escaping (ZaiError?) -> Void) {
        if self.isActive == false {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not excuted"))
            return
        }
        self.privateApi?.cancelOrder(Int(self.orderId!)!) { (err, res) in
            if res!["success"].intValue != 1 {
                self.status = NSNumber(value: OrderState.INVALID.rawValue)
                cb(ZaiError(errorType: .INVALID_ORDER))
            } else {
                self.status = NSNumber(value: OrderState.CANCELLED.rawValue)
                cb(nil)
            }
        }
    }
    
    @objc func monitor() {
        if self.isActive == false || self.orderId == nil{
            return
        }
        if self.delegate == nil {
            return
        }
        self.privateApi?.activeOrders(self.zaifOrder.currencyPair) { (err, res) in
            if err != nil {
                return
            }
            if res!["success"].intValue != 1 {
                return
            }
            
            let idExists = res?["return"].dictionaryValue.keys.contains(self.orderId!)
            if idExists == false {
                if self.isActive == false { // safety
                    return
                }
                self.status = NSNumber(value: OrderState.PROMISED.rawValue)
                self.promisedTime = NSNumber(value: Int64(NSDate().timeIntervalSince1970))
                self.promisedPrice = self.orderPrice!
                let newlyPromisedAmount = self.zaifOrder.amount - self.promisedAmount!.doubleValue
                self.promisedAmount = NSNumber(value: self.zaifOrder.amount)
                self.delegate?.orderPromised(order: self, price: self.promisedPrice!.doubleValue, amount: newlyPromisedAmount)
            } else {
                let promisedOrder = self.extractPromisedOrder(data: res)
                if promisedOrder == nil {
                    return
                }
                self.promisedAmount = NSNumber(value: promisedOrder!.promisedAmount)
                self.promisedTime = NSNumber(value: promisedOrder!.timestamp)
                self.delegate?.orderPartiallyPromised(order: self, price: self.orderPrice!.doubleValue, amount: promisedOrder!.newlyPromisedAmount)
            }
        }
    }
    
    fileprivate func extractPromisedOrder(data: JSON?) -> PromisedOrder? {
        let order = data?["return"].dictionaryValue[self.orderId!]?.dictionaryValue
        let timestamp = order?["timestamp"]?.int64Value
        if timestamp == nil || timestamp! <= self.promisedTime!.int64Value {
            return nil
        }
        let promisedAmount = self.zaifOrder.amount - (order?["amount"]?.doubleValue)!
        if promisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        let newlyPromisedAmount = promisedAmount - self.promisedAmount!.doubleValue
        if newlyPromisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        return PromisedOrder(promisedAmount: promisedAmount, newlyPromisedAmount: newlyPromisedAmount, timestamp: timestamp!)
    }
    
    internal func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        return nil
    }
    
    internal var currencyPair: CurrencyPair {
        get {
            return self.zaifOrder.currencyPair
        }
    }
    
    internal var orderAction: OrderAction {
        get {
            return self.zaifOrder.action
        }
    }
    
    internal var price: Double {
        get {
            if self.isPromised {
                return self.promisedPrice!.doubleValue
            } else {
                if let p = self.orderPrice {
                    return p.doubleValue
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
            return self.status.intValue == OrderState.PROMISED.rawValue
        }
    }
    
    internal var isActive: Bool {
        get {
            let s = self.status.intValue
            return OrderState(rawValue: s)!.isActive
        }
    }
    
    internal var privateApi: PrivateApi?
    internal var zaifOrder: ZaifSwift.Order!
    var promiseMonitorTimer: Timer!
    var delegate: OrderDelegate?
}
