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
    
    func setPassword(password: String) -> PasswordErrorType? {
        if let err = self.validatePassword(password: password) {
            return err
        }
        guard let encrypted = Crypt.hash(src: password, salt: self.salt) else {
            return .CRYPTION_ERROR
        }
        
        for exchange in self.exchanges {
            let ex = exchange as! Exchange
            if !ex.saveApiKey(cryptKey: password) {
                return .CRYPTION_ERROR
            }
        }
        self.password = encrypted
        self.ppw = password
        
        Database.getDb().saveContext()
        return nil
    }
    
    func loggout() {
        let exchange = self.activeExchange
        _ = exchange.saveApiKey(cryptKey: self.ppw!)
        exchange.trader.fund.delegate = nil
        
        for order in exchange.trader.activeOrders {
            order.activeOrderMonitor?.delegate = nil
        }
    }
    
    func isEqualPassword(password: String) -> Bool {
        if let p = self.ppw {
            return (p == password)
        } else {
            guard let encrypted = Crypt.hash(src: password, salt: self.salt) else {
                return false
            }
            return (self.password == encrypted)
        }
    }
    
    func validatePassword(password: String) -> PasswordErrorType? {
        return nil
    }
    
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        let fund = Fund(api: self.activeExchange.api)
        fund.getMarketCapitalization(cb)
    }
    
    func getExchange(exchangeName: String) -> Exchange? {
        var ret: Exchange?
        for exchange in self.exchanges {
            let ex = exchange as! Exchange
            ret = ex
            if ex.name == exchangeName {
                break
            }
        }
        return ret
    }
    
    var activeExchange: Exchange {
        return self.getExchange(exchangeName: self.activeExchangeName)!
    }
    
    var ppw: String?
}
