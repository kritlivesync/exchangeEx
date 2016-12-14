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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    convenience init?(order: BuyOrder, trader: Trader) {
        self.init(entity: TraderRepository.getInstance().longPositionDescription, insertInto: nil)
        
        if !order.isPromised {
            return nil
        }

        self.id = UUID().uuidString
        self.trader = trader
        let log = TradeLogRepository.getInstance().create(.OPEN_LONG_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: self.id)
        self.addLog(log)
    }
    
    override public var price: Double {
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
            var buyPrice = 0.0
            var sellPriceSum = 0.0
            var sellAmount = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    buyPrice = l.price.doubleValue
                } else if action == .UNWIND_LONG_POSITION {
                    sellAmount += l.amount.doubleValue
                    sellPriceSum += l.price.doubleValue * l.amount.doubleValue
                }
            }
            return sellPriceSum - (buyPrice * sellAmount)
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
        
        print("sell: " + balance.description)
        
        let order = SellOrder(
            currencyPair: self.currencyPair,
            price: price,
            amount: amt!,
            api: self.trader.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise(timeout: 30) { (err, promised) in
                    if promised {
                        let log = TradeLogRepository.getInstance().create(.UNWIND_LONG_POSITION, traderName: self.trader.name, account: self.trader.account, order: order, positionId: self.id)
                        self.addLog(log)
                        if self.balance < 0.0001 {
                            self.close()
                        }
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
}
