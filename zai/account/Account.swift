//
//  Account.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData


open class Account: NSManagedObject {
    
    func addExchange(exchange: Exchange) {
        let exchanges = self.mutableSetValue(forKey: "exchanges")
        exchanges.add(exchange)
        exchange.account = self
        if exchanges.count == 1 {
            self.activeExchangeName = exchange.name
        }
        Database.getDb().saveContext()
    }
    
    func setPassword(password: String) -> Bool {
        guard let encrypted = Crypt.hash(src: password, salt: self.salt) else {
            return false
        }
        self.password = encrypted
        Database.getDb().saveContext()
        return true
    }
    
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        let fund = Fund(api: self.activeExchange.api)
        fund.getMarketCapitalization(cb)
    }
    
    var activeExchange: Exchange {
        get {
            var ret: Exchange?
            for exchange in self.exchanges {
                let ex = exchange as! Exchange
                ret = ex
                if ex.name == self.activeExchangeName {
                    break
                }
            }
            return ret!
        }
    }
    
    var plainPassword: String?
}
