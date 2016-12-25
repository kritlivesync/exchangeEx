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
        
        self.status = NSNumber(value: PositionState.UNWINDING.rawValue)
        
        let balance = self.balance
        var amt = amount
        if amount == nil {
            // close this position completely
            amt = balance
        }
        if balance < amt! {
            amt = balance
        }
        
        let order = OrderRepository.getInstance().createSellOrder(currencyPair: self.currencyPair, price: price, amount: amt!, api: self.trader!.account.privateApi)
        
        order.excute() { (err, res) in
            cb(err)
            order.delegate = self
        }
    }
    
    // OrderDelegate
    override func orderPromised(order: Order, price: Double, amount: Double) {
        return
    }
    override func orderPartiallyPromised(order: Order, price: Double, amount: Double) {
        return
    }
    override func orderCancelled(order: Order) {
        return
    }
}
