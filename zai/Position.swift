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
}


class Position: NSManagedObject, PositionProtocol {
    
    func unwind(amount: Double?, price: Double?, cb: (ZaiError?) -> Void) {
        cb(ZaiError(errorType: .UNKNOWN_ERROR, message: "not implemented"))
    }

    var balance: Double {
        get { return 0.0 }
    }
    
    var profit: Double {
        get { return 0.0 }
    }

}


class LongPosition : Position {
    init?(order: BuyOrder, trader: Trader) {
        super.init(entity: TraderRepository.getInstance().positionDescription, insertIntoManagedObjectContext: nil)
        
        if !order.isPromised {
            return nil
        }
        self.id = NSUUID().UUIDString
        self.trader = trader
        self.buyLog = TradeLog(action: .OPEN_LONG_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.sellLogs = []
    }
    
    override internal var balance: Double {
        get {
            var balance = self.buyLog.amount.doubleValue
            for log in self.sellLogs {
                balance -= log.amount.doubleValue
            }
            return balance
        }
    }
    
    override internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.sellLogs {
                profit += log.price.doubleValue
            }
            profit -= self.buyLog.price.doubleValue
            return profit
        }
    }
    
    override internal func unwind(amount: Double?=nil, price: Double?, cb: (ZaiError?) -> Void) {
        let balance = self.balance
        var amt = amount
        if amount == nil {
            // close this position completely
            amt = balance
        }
        if balance < amt {
            amt = balance
        }
        
        let order = SellOrder(
            currencyPair: CurrencyPair(rawValue: self.buyLog.currencyPair)!,
            price: price,
            amount: amt!,
            api: self.trader.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(action: .UNWIND_LONG_POSITION, traderName: self.trader.name, account: self.trader.account, order: order, positionId: self.id)
                        self.sellLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    private let buyLog: TradeLog! = nil
    private var sellLogs: [TradeLog]! = nil
}


class ShortPosition : Position {
    init?(order: BuyOrder, trader: Trader) {
        super.init(entity: TraderRepository.getInstance().positionDescription, insertIntoManagedObjectContext: nil)
        
        if !order.isPromised {
            return nil
        }
        self.id = NSUUID().UUIDString
        self.sellLog = TradeLog(action: .OPEN_SHORT_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.buyLogs = []
    }
    
    override internal var balance: Double {
        get {
            var balance = self.sellLog.amount.doubleValue
            for log in self.buyLogs {
                balance -= log.amount.doubleValue
            }
            return balance
        }
    }
    
    override internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.buyLogs {
                profit += log.price.doubleValue
            }
            profit -= self.sellLog.price.doubleValue
            return profit
        }
    }
    
    override internal func unwind(amount: Double?=nil, price: Double?, cb: (ZaiError?) -> Void) {
        let balance = self.balance
        var amt = amount
        if amount == nil {
            // close this position completely
            amt = balance
        }
        if balance < amt {
            amt = balance
        }
        
        let order = SellOrder(
            currencyPair: CurrencyPair(rawValue: self.sellLog.currencyPair)!,
            price: price,
            amount: amt!,
            api: self.trader.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(action: .UNWIND_SHORT_POSITION, traderName: self.trader.name, account: self.trader.account, order: order, positionId: self.id)
                        self.buyLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    private let sellLog: TradeLog! = nil
    private var buyLogs: [TradeLog]! = nil
    
}