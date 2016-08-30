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


public class Trader: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(name: String, account: Account) {
        self.init(entity: TraderRepository.getInstance().traderDescription, insertIntoManagedObjectContext: nil)
        
        self.name = name
        self.status = TraderState.ACTIVE.rawValue
        self.account = account
        self.positions = []
    }
    
    func createLongPosition(currencyPair: CurrencyPair, price: Double?, amount: Double, cb: (ZaiError?) -> Void) {
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
                            let position = LongPosition(order: order, trader: self)
                            self.addPosition(position!)
                            cb(nil)
                        }
                    }
                }
            }
        }
    }
}
