//
//  Position.swift
//  
//
//  Created by Kyota Watanabe on 8/23/16.
//
//

import Foundation
import CoreData

import ZaifSwift


internal protocol PositionProtocol {
    func unwind(_ amount: Double?, price: Double?, cb: @escaping (ZaiError?, Double) -> Void) -> Void
    func delete()
    func calculateUnrealizedProfit(marketPrice: Double) -> Double
    
    var price: Double { get set }
    var amount: Double { get set }
    var balance: Double { get }
    var cost: Double { get }
    var profit: Double { get }
    var type: String { get }
    var timestamp: Int64 { get }
    
    var isOpen: Bool { get }
    var isClosed: Bool { get }
    var isUnwinding: Bool { get }
    var isOpening: Bool { get }
    var isDelete: Bool { get }
    var isPartial: Bool { get }
}

protocol PositionDelegate {
    func opendPosition(position: Position, promisedOrder: PromisedOrder)
    func unwindPosition(position: Position, promisedOrder: PromisedOrder)
    func closedPosition(position: Position, promisedOrder: PromisedOrder?)
}

enum PositionState: Int {
    case OPENING=0
    case OPEN=1
    case CLOSED=2
    case UNWINDING=3
    case WAITING=4
    case DELETED=5
    case PARTIAL=6
    
    func toString() -> String {
        switch self {
        case .OPENING:
            return "\(LabelResource.positionStateOpening)"
        case .OPEN:
            return "\(LabelResource.positionStateOpen)"
        case .CLOSED:
            return "\(LabelResource.positionStateClosed)"
        case .UNWINDING:
            return "\(LabelResource.positionStateUnwinding)"
        case .WAITING:
            return "\(LabelResource.positionStateWaiting)"
        case .DELETED:
            return "\(LabelResource.positionStateDeleted)"
        case .PARTIAL:
            return "\(LabelResource.positionStatePartial)"
        }
    }
    
    var isActive: Bool {
        switch self {
        case .PARTIAL, .OPEN, .UNWINDING:
            return true
        default:
            return false
        }
    }
    
    var isOpen: Bool {
        return self == .OPEN
    }
    
    var isOpening: Bool {
        return self == .OPENING
    }
    
    var isClosed: Bool {
        return self == .CLOSED
    }
    
    var isWaiting: Bool {
        return self == .WAITING
    }
    
    var isDelete: Bool {
        return self == .DELETED
    }
    
    var isPartial: Bool {
        return self == .PARTIAL
    }
    
    var isUnwinding: Bool {
        return self == .UNWINDING
    }
}


public class Position: NSManagedObject, PositionProtocol, PromisedOrderDelegate {
    func unwind(_ amount: Double?, price: Double?, cb: @escaping (ZaiError?, Double) -> Void) {
        cb(ZaiError(errorType: .UNKNOWN_ERROR, message: "not implemented"), 0.0)
    }
    
    func addLog(_ log: TradeLog) {
        self.addToTradeLogs(log)
    }
    
    func open() {
        self.status = NSNumber(value: PositionState.OPEN.rawValue)
        Database.getDb().saveContext()
    }
    
    func close() {
        self.status = NSNumber(value: PositionState.CLOSED.rawValue)
        Database.getDb().saveContext()
    }
    
    func delete() {
        self.status = NSNumber(value: PositionState.DELETED.rawValue)
        Database.getDb().saveContext()
    }
    
    func partial() {
        self.status = NSNumber(value: PositionState.PARTIAL.rawValue)
        Database.getDb().saveContext()
    }
    
    func calculateUnrealizedProfit(marketPrice: Double) -> Double {
        return 0.0
    }
    
    var price: Double {
        get { return 0.0 }
        set {}
    }
    
    var amount: Double {
        get { return 0.0 }
        set {}
    }

    var balance: Double {
        get { return 0.0 }
    }
    
    var cost: Double {
        get {
            return self.price * self.amount
        }
    }
    
    var profit: Double {
        get { return 0.0 }
    }
    
    var currencyPair: ApiCurrencyPair {
        get { return ApiCurrencyPair.BTC_JPY }
    }
    
    var type: String {
        get { return "" }
    }
    
    var timestamp: Int64 {
        get { return 0 }
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
            if order.promiseMonitor == nil {
                order.api = self.trader?.exchange.api
                order.startWatchingPromise()
            }
            order.api = self.trader!.exchange.api
            return order
        }
        set {
            if let newOrder = newValue {
                newOrder.delegate = self
                if newOrder.promiseMonitor == nil {
                    newOrder.startWatchingPromise()
                }
            } else {
                if let order = self.activeOrder {
                    order.delegate = nil
                    order.stopWatchingPromise()
                }
            }
            self.activeOrder = newValue
            Database.getDb().saveContext()
        }
    }
    
    var isOpen: Bool {
        return PositionState(rawValue: self.status.intValue)!.isOpen
    }
    
    var isClosed: Bool {
        return PositionState(rawValue: self.status.intValue)!.isClosed
    }
    
    var isUnwinding: Bool {
        return PositionState(rawValue: self.status.intValue)!.isUnwinding
    }
    
    var isOpening: Bool {
        return PositionState(rawValue: self.status.intValue)!.isOpening
    }
    
    var isDelete: Bool {
        return PositionState(rawValue: self.status.intValue)!.isDelete
    }
    
    var isPartial: Bool {
        return PositionState(rawValue: self.status.intValue)!.isPartial
    }
    
    // OrderDelegate
    func orderPromised(order: Order, promisedOrder: PromisedOrder) {
        return
    }
    func orderPartiallyPromised(order: Order, promisedOrder: PromisedOrder) {
        return
    }
    func orderCancelled(order: Order) {
        return
    }
    
    var delegate: PositionDelegate?
}
