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
    
    var balance: Double { get }
    var profit: Double { get }
    var cost: Double { get }
    var type: String { get }
}

enum PositionState {
    case OPEN
    case CLOSED
    case CLOSING
}


class Position: NSManagedObject, PositionProtocol {
    internal func unwind(_ amount: Double?, price: Double?, cb: @escaping (ZaiError?) -> Void) {
        cb(ZaiError(errorType: .UNKNOWN_ERROR, message: "not implemented"))
    }
    
    func addLog(_ log: TradeLog) {
        let logs = self.mutableOrderedSetValue(forKey: "tradeLogs")
        logs.add(log)
        Database.getDb().saveContext()
    }

    var balance: Double {
        get { return 0.0 }
    }
    
    var profit: Double {
        get { return 0.0 }
    }
    
    var cost: Double {
        get { return 0.0 }
    }
    
    var currencyPair: CurrencyPair {
        get { return .BTC_JPY }
    }
    
    var type: String {
        get { return "" }
    }

    var status: PositionState = .OPEN
}
