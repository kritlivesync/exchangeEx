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

protocol PromisedOrderDelegate {
    func orderPromised(order: Order, price: Double, amount: Double)
    func orderPartiallyPromised(order: Order, price: Double, amount: Double)
    func orderCancelled(order: Order)
}



@objc(Order)
public class Order: NSManagedObject, ActiveOrderDelegate {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
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
                    self.orderTime = Int64(Date().timeIntervalSince1970) as NSNumber
                    self.orderPrice = res!["return"]["order_price"].doubleValue as NSNumber?
                    self.status = NSNumber(value: OrderState.ORDERING.rawValue)
                    Database.getDb().saveContext()
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
                self.delegate?.orderCancelled(order: self)
                cb(nil)
            }
        }
    }
    
    func monitorPromised(activeOrders: [String: ActiveOrder]) {
        if self.orderId == nil {
            return
        }
        if let activeOrder = activeOrders[self.orderId!] {
            let promisedOrder = self.extractPromisedOrder(order: activeOrder)
            if promisedOrder == nil {
                return
            }
            self.promisedAmount = NSNumber(value: promisedOrder!.promisedAmount)
            self.promisedTime = NSNumber(value: promisedOrder!.timestamp)
            self.delegate?.orderPartiallyPromised(order: self, price: self.orderPrice!.doubleValue, amount: promisedOrder!.newlyPromisedAmount)
        } else {
            if self.isActive == false { // safety
                return
            }
            self.status = NSNumber(value: OrderState.PROMISED.rawValue)
            self.promisedTime = NSNumber(value: Int64(NSDate().timeIntervalSince1970))
            self.promisedPrice = 0.0
            if let price = self.orderPrice {
                self.promisedPrice = price
            }
            var newlyPromisedAmount = self.zaifOrder.amount
            if let amount = self.promisedAmount {
                newlyPromisedAmount = self.zaifOrder.amount - amount.doubleValue
            }
            self.promisedAmount = NSNumber(value: self.zaifOrder.amount)
            self.delegate?.orderPromised(order: self, price: self.promisedPrice!.doubleValue, amount: newlyPromisedAmount)
        }
    }
    
    fileprivate func extractPromisedOrder(order: ActiveOrder) -> PromisedOrder? {
        if order.timestamp <= self.promisedTime!.int64Value {
            return nil
        }
        let promisedAmount = self.zaifOrder.amount - order.amount
        if promisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        let newlyPromisedAmount = promisedAmount - self.promisedAmount!.doubleValue
        if newlyPromisedAmount < self.zaifOrder.currencyPair.minOrderUnit {
            return nil
        }
        return PromisedOrder(promisedAmount: promisedAmount, newlyPromisedAmount: newlyPromisedAmount, timestamp: order.timestamp)
    }
    
    internal func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        return nil
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
    
    // ActiveOrderDelegate
    func revievedActiveOrders(activeOrders: [String: ActiveOrder]) {
        self.monitorPromised(activeOrders: activeOrders)
    }
    
    internal var privateApi: PrivateApi?
    internal lazy var zaifOrder: ZaifSwift.Order = {
        return self.createOrder(CurrencyPair(rawValue: self.currencyPair)!, price: self.orderPrice as Double?, amount: Double(self.orderAmount))!
    }()
    var activeOrderMonitor: ActiveOrderMonitor?
    var promiseMonitorTimer: Timer!
    var delegate: PromisedOrderDelegate?
}
