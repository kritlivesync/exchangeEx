//
//  LongPosition.swift
//  
//
//  Created by 渡部郷太 on 8/31/16.
//
//

import Foundation
import CoreData

import ZaifSwift


@objc(LongPosition)
class LongPosition: Position {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init?(order: BuyOrder, trader: Trader) {
        self.init(entity: TraderRepository.getInstance().longPositionDescription, insertIntoManagedObjectContext: nil)
        
        if !order.isPromised {
            return nil
        }

        self.id = NSUUID().UUIDString
        self.trader = trader
        let log = TradeLogRepository.getInstance().create(.OPEN_LONG_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.addLog(log)
    }
    
    override internal var balance: Double {
        get {
            var balance = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    balance += l.amount.doubleValue
                } else if action == .UNWIND_LONG_POSITION {
                    balance -= l.amount.doubleValue
                }
            }
            return balance
        }
    }
    
    override internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    profit -= l.price.doubleValue * l.amount.doubleValue
                } else if action == .UNWIND_LONG_POSITION {
                    profit += l.price.doubleValue * l.amount.doubleValue
                }
            }
            return profit
        }
    }
    
    override internal var cost: Double {
        get {
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    return l.price.doubleValue
                }
            }
            return 0.0
        }
    }
    
    override internal var currencyPair: CurrencyPair {
        get {
            var currencyPair = CurrencyPair.BTC_JPY
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    currencyPair = CurrencyPair(rawValue: l.currencyPair)!
                }
            }
            return currencyPair
        }
    }
    
    override internal var type: String {
        get {
            return "Long"
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
            currencyPair: self.currencyPair,
            price: price,
            amount: amt!,
            api: self.trader.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLogRepository.getInstance().create(.UNWIND_LONG_POSITION, traderName: self.trader.name, account: self.trader.account, order: order, positionId: self.id)
                        self.addLog(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
}
