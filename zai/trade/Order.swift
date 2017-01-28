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
    let currencyPair: String
    let action: String
    let price: Double
    let promisedAmount: Double
    let newlyPromisedAmount: Double
    let timestamp: Int64
}

protocol PromisedOrderDelegate {
    func orderPromised(order: Order, promisedOrder: PromisedOrder)
    func orderPartiallyPromised(order: Order, promisedOrder: PromisedOrder)
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
        
        self.api?.trade(order: self, retryCount: 2) { (err, orderId, price) in
            if let e = err {
                self.status = NSNumber(value: OrderState.INVALID.rawValue)
                cb(ZaiError(errorType: .INVALID_ORDER, message: e.message), nil)
            } else {
                self.orderId = orderId
                self.orderTime = Int64(Date().timeIntervalSince1970) as NSNumber
                self.orderPrice = price as NSNumber?
                self.status = NSNumber(value: OrderState.ORDERING.rawValue)
                Database.getDb().saveContext()
                cb(nil, self.orderId!)
            }
        }
    }
    
    internal func cancel(_ cb: @escaping (ZaiError?) -> Void) {
        if self.isActive == false {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order is not excuted"))
            return
        }
        let activeOrder = ActiveOrder(id: self.orderId!, action: self.action, currencyPair: ApiCurrencyPair(rawValue: self.currencyPair)!, price: self.orderPrice!.doubleValue, amount: self.orderAmount.doubleValue, timestamp: self.orderTime!.int64Value)
        self.api?.cancelOrder(order: activeOrder, retryCount: 2) { err in
            if let _ = err {
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
            guard let promisedOrder = self.extractPromisedOrder(order: activeOrder) else {
                return
            }
            self.promisedAmount = NSNumber(value: promisedOrder.promisedAmount)
            self.promisedTime = NSNumber(value: promisedOrder.timestamp)
            self.delegate?.orderPartiallyPromised(order: self, promisedOrder: promisedOrder)
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
            var newlyPromisedAmount = self.orderAmount.doubleValue
            if let amount = self.promisedAmount {
                newlyPromisedAmount = self.orderAmount.doubleValue - amount.doubleValue
            }
            self.promisedAmount = NSNumber(value: self.orderAmount.doubleValue)
            let promisedOrder = PromisedOrder(currencyPair: self.currencyPair, action: self.action, price: self.promisedPrice!.doubleValue, promisedAmount: self.promisedAmount!.doubleValue, newlyPromisedAmount: newlyPromisedAmount, timestamp: Int64(Date().timeIntervalSince1970))
            self.delegate?.orderPromised(order: self, promisedOrder: promisedOrder)
        }
    }
    
    fileprivate func extractPromisedOrder(order: ActiveOrder) -> PromisedOrder? {
        if order.timestamp <= self.promisedTime!.int64Value {
            return nil
        }
        let promisedAmount = self.orderAmount.doubleValue - order.amount
        let orderUnit = self.api!.orderUnit(currencyPair: ApiCurrencyPair(rawValue: self.currencyPair)!)
        if promisedAmount < orderUnit {
            return nil
        }
        let newlyPromisedAmount = promisedAmount - self.promisedAmount!.doubleValue
        if newlyPromisedAmount < orderUnit {
            return nil
        }
        return PromisedOrder(currencyPair: order.currencyPair.rawValue, action: order.action, price: order.price, promisedAmount: promisedAmount, newlyPromisedAmount: newlyPromisedAmount, timestamp: order.timestamp)
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
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "Order"
    }
    
    // ActiveOrderDelegate
    func revievedActiveOrders(activeOrders: [String: ActiveOrder]) {
        self.monitorPromised(activeOrders: activeOrders)
    }
    
    internal var api: Api?
    var activeOrderMonitor: ActiveOrderMonitor?
    var promiseMonitorTimer: Timer!
    var delegate: PromisedOrderDelegate?
}
