//
//  Position.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData

import ZaifSwift


internal protocol PositionProtocol {
    func unwind(_ amount: Double?, price: Double?, cb: @escaping (ZaiError?) -> Void) -> Void
    
    var price: Double { get }
    var balance: Double { get }
    var profit: Double { get }
    var type: String { get }
}

protocol PositionDelegate {
    func opendPosition(position: Position)
    func unwindPosition(position: Position)
    func closedPosition(position: Position)
}

enum PositionState: Int {
    case OPENING=0
    case OPEN=1
    case CLOSED=2
    case UNWINDING=3
    case WAITING=4
    
    func toString() -> String {
        switch self {
        case .OPENING:
            return "Opening"
        case .OPEN:
            return "Open"
        case .CLOSED:
            return "Closed"
        case .UNWINDING:
            return "Unwinding"
        case .WAITING:
            return "Waiting"
        }
    }
    
    var isActive: Bool {
        switch self {
        case .OPENING, .OPEN, .UNWINDING:
            return true
        case .CLOSED, .WAITING:
            return false
        }
    }
}


public class Position: NSManagedObject, PositionProtocol, PromisedOrderDelegate {
    internal func unwind(_ amount: Double?, price: Double?, cb: @escaping (ZaiError?) -> Void) {
        cb(ZaiError(errorType: .UNKNOWN_ERROR, message: "not implemented"))
    }
    
    func addLog(_ log: TradeLog) {
        let logs = self.mutableOrderedSetValue(forKey: "tradeLogs")
        logs.add(log)
        Database.getDb().saveContext()
    }
    
    func open() {
        self.status = NSNumber(value: PositionState.OPEN.rawValue)
        Database.getDb().saveContext()
    }
    
    func close() {
        self.status = NSNumber(value: PositionState.CLOSED.rawValue)
        Database.getDb().saveContext()
    }
    
    var price: Double {
        get { return 0.0 }
    }

    var balance: Double {
        get { return 0.0 }
    }
    
    var profit: Double {
        get { return 0.0 }
    }
    
    var currencyPair: CurrencyPair {
        get { return .BTC_JPY }
    }
    
    var type: String {
        get { return "" }
    }
    
    var lastTrade: TradeLog? {
        get {
            if self.tradeLogs.count > 0 {
                return self.tradeLogs.lastObject as? TradeLog
            } else {
                return nil
            }
        }
    }
    
    var order: Order? {
        get {
            guard let order = self.activeOrder else {
                return nil
            }
            order.delegate = self
            if order.activeOrderMonitor == nil {
                order.activeOrderMonitor = ActiveOrderMonitor(currencyPair: CurrencyPair(rawValue: order.currencyPair)!, api: self.trader!.account.privateApi)
                order.activeOrderMonitor?.delegate = order
            }
            return order
        }
        set {
            if let newOrder = newValue {
                newOrder.delegate = self
                if newOrder.activeOrderMonitor == nil {
                    newOrder.activeOrderMonitor = ActiveOrderMonitor(currencyPair: CurrencyPair(rawValue: newOrder.currencyPair)!, api: self.trader!.account.privateApi)
                    newOrder.activeOrderMonitor?.delegate = newOrder
                }
            } else {
                if let order = self.activeOrder {
                    order.delegate = nil
                    order.activeOrderMonitor?.delegate = nil
                }
            }
            self.activeOrder = newValue
            Database.getDb().saveContext()
        }
    }
    
    // OrderDelegate
    func orderPromised(order: Order, price: Double, amount: Double) {
        return
    }
    func orderPartiallyPromised(order: Order, price: Double, amount: Double) {
        return
    }
    func orderCancelled(order: Order) {
        return
    }
    
    var delegate: PositionDelegate?
}
