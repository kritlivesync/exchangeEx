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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    convenience init?(order: SellOrder, trader: Trader) {
        self.init(entity: TraderRepository.getInstance().shortPositionDescription, insertInto: nil)
        
        if !order.isPromised {
            return nil
        }
        self.id = UUID().uuidString
        
        let log = TradeLogRepository.getInstance().create(.OPEN_SHORT_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.addLog(log)
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
                    profit += l.price.doubleValue * l.amount.doubleValue
                } else if action == .UNWIND_SHORT_POSITION {
                    profit -= l.price.doubleValue * l.amount.doubleValue
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
                if action == .OPEN_SHORT_POSITION {
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
                if action == .OPEN_SHORT_POSITION {
                    currencyPair = CurrencyPair(rawValue: l.currencyPair)!
                }
            }
            return currencyPair
        }
    }
    
    override internal var type: String {
        get {
            return "Short"
        }
    }
    
    override internal func unwind(_ amount: Double?=nil, price: Double?, cb: @escaping (ZaiError?) -> Void) {
        if self.status.intValue != PositionState.OPEN.rawValue {
            cb(nil)
            return
        }
        
        self.status = NSNumber(value: PositionState.CLOSING.rawValue)
        
        let balance = self.balance
        var amt = amount
        if amount == nil {
            // close this position completely
            amt = balance
        }
        if balance < amt! {
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
                order.waitForPromise(timeout: 10) { (err, promised) in
                    if promised {
                        let log = TradeLog(action: .UNWIND_SHORT_POSITION, traderName: self.trader.name, account: self.trader.account, order: order, positionId: self.id)
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
