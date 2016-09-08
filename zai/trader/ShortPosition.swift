//
//  ShortPosition.swift
//  
//
//  Created by 渡部郷太 on 8/31/16.
//
//

import Foundation
import CoreData

import ZaifSwift


@objc(ShortPosition)
class ShortPosition: Position {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init?(order: BuyOrder, trader: Trader) {
        self.init(entity: TraderRepository.getInstance().shortPositionDescription, insertIntoManagedObjectContext: nil)
        
        if !order.isPromised {
            return nil
        }
        self.id = NSUUID().UUIDString
        self.sellLog = TradeLog(action: .OPEN_SHORT_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.buyLogs = []
    }
    
    override internal var balance: Double {
        get {
            var balance = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_SHORT_POSITION {
                    balance += l.amount.doubleValue
                } else if action == .UNWIND_SHORT_POSITION {
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
                if action == .OPEN_SHORT_POSITION {
                    profit += l.price.doubleValue
                } else if action == .UNWIND_SHORT_POSITION {
                    profit -= l.price.doubleValue
                }
            }
            return profit
        }
    }
    
    override internal var type: String {
        get {
            return "Short"
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
    
    internal var sellLog: TradeLog! = nil
    internal var buyLogs: [TradeLog]! = nil

}
