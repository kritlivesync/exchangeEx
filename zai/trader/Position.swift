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
    func unwind(amount: Double?, price: Double?, cb: (ZaiError?) -> Void)
    
    var balance: Double { get }
    var profit: Double { get }
    var type: String { get }
}


class Position: NSManagedObject, PositionProtocol {
    
    func unwind(amount: Double?, price: Double?, cb: (ZaiError?) -> Void) {
        cb(ZaiError(errorType: .UNKNOWN_ERROR, message: "not implemented"))
    }
    
    func addLog(log: TradeLog) {
        let logs = self.mutableSetValueForKey("tradeLogs")
        logs.addObject(log)
        Database.getDb().saveContext()
    }

    var balance: Double {
        get { return 0.0 }
    }
    
    var profit: Double {
        get { return 0.0 }
    }
    
    var type: String {
        get { return "" }
    }

}
