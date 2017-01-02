//
//  Account.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData

import ZaifSwift


open class Account: NSManagedObject {
    
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        let fund = Fund(api: self.activeExchange.api)
        fund.getMarketCapitalization(cb)
    }
    
    var activeExchange: ExchangeAccount {
        get {
            var ret: ExchangeAccount?
            for exchange in self.exchanges {
                let ex = exchange as! ExchangeAccount
                ret = ex
                if ex.name == self.activeExchangeName {
                    break
                }
            }
            return ret!
        }
    }
}
