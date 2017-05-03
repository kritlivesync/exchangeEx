//
//  Order+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 12/19/16.
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
            }
        }
    }
}


protocol PromisedOrderDelegate {
    func orderPromised(order: Order, promisedOrder: PromisedOrder)
    func orderPartiallyPromised(order: Order, promisedOrder: PromisedOrder)
    func orderCancelled(order: Order)
}



@objc(Order)
public class Order: NSManagedObject, PromiseMonitorDelegate {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    internal func excute(_ cb: @escaping (ZaiError?, String?) -> Void) {
        if self.status.intValue != OrderState.WAITING.rawValue || self.orderId != nil {
            // todo async
            cb(ZaiError(errorType: .INVALID_ORDER, message: "order already active"), nil)
            return
        }
        
        self.api?.trade(order: self, retryCount: 2) { (err, orderId, price, amount) in
            DispatchQueue.main.async {
                if let e = err {
                    self.status = NSNumber(value: OrderState.INVALID.rawValue)
                    self.stopWatchingPromise()
                    switch e.errorType {
                    case ApiErrorType.NO_PERMISSION:
                        cb(ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: getResource().apiKeyNoPermission), nil)
                    case ApiErrorType.NONCE_NOT_INCREMENTED:
                        cb(ZaiError(errorType: .NONCE_NOT_INCREMENTED, message: getResource().apiKeyNonceNotIncremented), nil)
                    case ApiErrorType.INVALID_API_KEY:
                        cb(ZaiError(errorType: .INVALID_API_KEYS, message: getResource().invalidApiKeyRestricted), nil)
                    case ApiErrorType.CONNECTION_ERROR:
                        cb(ZaiError(errorType: .CONNECTION_ERROR, message: Resource.networkConnectionError), nil)
                    case ApiErrorType.INVALID_ORDER_AMOUNT:
                        let pair = ApiCurrencyPair(rawValue: self.currencyPair)!
                        let orderUnit = self.api!.orderUnit(currencyPair: pair)
                        cb(ZaiError(errorType: .INVALID_ORDER_AMOUNT, message: Resource.insufficientAmount(minAmount: orderUnit, currency: pair.principal)), nil)
                    case ApiErrorType.INSUFFICIENT_FUNDS:
                        cb(ZaiError(errorType: .INSUFFICIENT_FUNDS, message: Resource.insufficientFunds), nil)
                    default:
                        cb(ZaiError(errorType: .INVALID_ORDER, message: Resource.unknownError), nil)
                    }
                } else {
                    self.orderId = orderId
                    self.orderTime = Int64(Date().timeIntervalSince1970) as NSNumber
                    self.orderPrice = price as NSNumber?
                    self.orderAmount = amount as NSNumber
                    self.status = NSNumber(value: OrderState.ORDERING.rawValue)
                    self.startWatchingPromise()
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
        
        let activeOrder = ActiveOrder(id: self.orderId!, action: self.action, currencyPair: ApiCurrencyPair(rawValue: self.currencyPair)!, price: self.orderPrice!.doubleValue, amount: self.orderAmount.doubleValue, timestamp: self.orderTime!.int64Value)
        self.api?.cancelOrder(order: activeOrder, retryCount: 2) { err in
            DispatchQueue.main.async {
                if let e = err {
                    switch e.errorType {
                    case ApiErrorType.NO_PERMISSION:
                        cb(ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: getResource().apiKeyNoPermission))
                    case ApiErrorType.NONCE_NOT_INCREMENTED:
                        cb(ZaiError(errorType: .NONCE_NOT_INCREMENTED, message: getResource().apiKeyNonceNotIncremented))
                    case ApiErrorType.CONNECTION_ERROR:
                        cb(ZaiError(errorType: .CONNECTION_ERROR, message: Resource.networkConnectionError))
                    case ApiErrorType.ORDER_NOT_FOUND:
                        // bitFlyer api returns orderNotFound error when using child_order_acceptance_id to cancel order
                        self.status = NSNumber(value: OrderState.CANCELLED.rawValue)
                        self.delegate?.orderCancelled(order: self)
                        cb(nil)
                    default:
                        cb(ZaiError(errorType: .INVALID_ORDER, message: Resource.unknownError))
                    }
                } else {
                    self.status = NSNumber(value: OrderState.CANCELLED.rawValue)
                    self.delegate?.orderCancelled(order: self)
                    cb(nil)
                }
            }
        }
    }
    
    public func startWatchingPromise() {
        self.promiseMonitor = PromiseMonitor(order: self, api: self.api!)
        DispatchQueue.main.asyncAfter(deadline: .now() + self.promiseMonitor!.monitoringInterval.double) {
            self.promiseMonitor?.delegate = self
        }
    }
    
    public func stopWatchingPromise() {
        self.promiseMonitor?.delegate = nil
        self.promiseMonitor = nil
    }
    
    internal var isPromised: Bool {
        return self.status.intValue == OrderState.PROMISED.rawValue
    }
    
    internal var isActive: Bool {
        return OrderState(rawValue: self.status.intValue)!.isActive
    }
    
    var isCanceling: Bool {
        return self.status.intValue == OrderState.CANCELING.rawValue
    }
    
    var isCancelled: Bool {
        return self.status.intValue == OrderState.CANCELLED.rawValue
    }
    
    var isInvalid: Bool {
        return OrderState(rawValue: self.status.intValue)! == .INVALID
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "Order"
    }
    
    // PromiseMonitorDelegate
    func promised(promisedOrder: PromisedOrder) {
        if self.isActive == false { // safety
            return
        }
        self.status = NSNumber(value: OrderState.PROMISED.rawValue)
        self.promisedTime = NSNumber(value: Int64(NSDate().timeIntervalSince1970))
        self.promisedPrice = 0.0
        if let price = self.orderPrice {
            self.promisedPrice = price
        }
        self.promisedAmount = NSNumber(value: self.orderAmount.doubleValue)
        self.delegate?.orderPromised(order: self, promisedOrder: promisedOrder)
    }
    
    func partiallyPromisedOrder(promisedOrder: PromisedOrder) {
        self.promisedAmount = NSNumber(value: promisedOrder.promisedAmount)
        self.promisedTime = NSNumber(value: promisedOrder.timestamp)
        self.delegate?.orderPartiallyPromised(order: self, promisedOrder: promisedOrder)
    }
    
    func invalidated() {
        self.delegate?.orderCancelled(order: self)
        self.stopWatchingPromise()
    }
    
    internal var api: Api?
    var promiseMonitor: PromiseMonitor?
    var delegate: PromisedOrderDelegate?
}
