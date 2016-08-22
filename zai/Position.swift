//
//  Position.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal protocol PositionProtocol {
    func unwind(amount: Double?, price: Double?, cb: (ZaiError?) -> Void)
    
    var balance: Double { get }
    var profit: Double { get }
    var id: String { get }
}


class LongPosition : PositionProtocol {
    init?(traderName: String, account: Account, order: BuyOrder) {
        if !order.isPromised {
            return nil
        }
        self.id = NSUUID().UUIDString
        self.buyLog = TradeLog(action: .OPEN_LONG_POSITION, traderName: traderName, account: account, order: order, positionId: self.id)
        self.sellLogs = []
        self.account = account
        self.traderName = traderName
    }
    
    internal var balance: Double {
        get {
            var balance = self.buyLog.amount.doubleValue
            for log in self.sellLogs {
                balance -= log.amount.doubleValue
            }
            return balance
        }
    }
    
    internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.sellLogs {
                profit += log.price.doubleValue
            }
            profit -= self.buyLog.price.doubleValue
            return profit
        }
    }
    
    internal func unwind(amount: Double?=nil, price: Double?, cb: (ZaiError?) -> Void) {
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
            api: self.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(action: .UNWIND_LONG_POSITION, traderName: self.traderName, account: self.account, order: order, positionId: self.id)
                        self.sellLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    internal let id: String
    private let buyLog: TradeLog
    private var sellLogs: [TradeLog]
    private let account: Account
    private let traderName: String
}


class ShortPosition : PositionProtocol{
    init?(traderName: String, account: Account, order: SellOrder) {
        if !order.isPromised {
            return nil
        }
        self.id = NSUUID().UUIDString
        self.sellLog = TradeLog(action: .OPEN_SHORT_POSITION, traderName: traderName, account: account, order: order, positionId: self.id)
        self.buyLogs = []
        self.account = account
        self.traderName = traderName
    }
    
    internal var balance: Double {
        get {
            var balance = self.sellLog.amount.doubleValue
            for log in self.buyLogs {
                balance -= log.amount.doubleValue
            }
            return balance
        }
    }
    
    internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.buyLogs {
                profit += log.price.doubleValue
            }
            profit -= self.sellLog.price.doubleValue
            return profit
        }
    }
    
    internal func unwind(amount: Double?=nil, price: Double?, cb: (ZaiError?) -> Void) {
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
            api: self.account.privateApi)!
        
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(action: .UNWIND_SHORT_POSITION, traderName: self.traderName, account: self.account, order: order, positionId: self.id)
                        self.buyLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    internal let id: String
    private let sellLog: TradeLog
    private var buyLogs: [TradeLog]
    private let account: Account
     private let traderName: String
}