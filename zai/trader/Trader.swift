//
//  Trader.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData

import ZaifSwift


public enum TraderState : String {
    case ACTIVE = "active"
    case IDLE = "idle"
}


open class Trader: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    convenience init(name: String, account: Account) {
        self.init(entity: TraderRepository.getInstance().traderDescription, insertInto: nil)
        
        self.name = name
        self.status = TraderState.ACTIVE.rawValue
        self.account = account
        self.positions = []
    }
    
    func addPosition(_ position: Position) {
        let positions = self.mutableOrderedSetValue(forKey: "positions")
        positions.add(position)
        Database.getDb().saveContext()
    }
    
    func createLongPosition(_ currencyPair: CurrencyPair, price: Double?, amount: Double, cb: @escaping (ZaiError?) -> Void) {
        let order = BuyOrder(currencyPair: currencyPair, price: price, amount: amount, api: self.account.privateApi)!
        order.excute() { (err, orderId) in
            if let e = err {
                cb(e)
            } else {
                order.waitForPromise() { (err, promised) in
                    if let e = err {
                        cb(e)
                    } else {
                        if promised {
                            let position = PositionRepository.getInstance().createLongPosition(order, trader: self)!
                            self.addPosition(position)
                            cb(nil)
                        }
                    }
                }
            }
        }
    }
}
