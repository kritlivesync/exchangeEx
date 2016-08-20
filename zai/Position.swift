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
}


class LongPosition : PositionProtocol {
    init?(order: BuyOrder, api: PrivateApi) {
        if !order.isPromised {
            return nil
        }
        self.buyLog = TradeLog(order: order)
        self.sellLogs = []
        self.privateApi = api
    }
    
    internal var balance: Double {
        get {
            var balance = self.buyLog.amount
            for log in self.sellLogs {
                balance -= log.amount
            }
            return balance
        }
    }
    
    internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.sellLogs {
                profit += log.price
            }
            profit -= self.buyLog.price
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
        
        let order = SellOrder(currencyPair: self.buyLog.currencyPair, price: price, amount: amt!, api: self.privateApi)!
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(order: order)
                        self.sellLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    private let buyLog: TradeLog
    private var sellLogs: [TradeLog]
    private let privateApi: PrivateApi
}


class ShortPosition : PositionProtocol{
    init?(order: SellOrder, api: PrivateApi) {
        if !order.isPromised {
            return nil
        }
        self.sellLog = TradeLog(order: order)
        self.buyLogs = []
        self.privateApi = api
    }
    
    internal var balance: Double {
        get {
            var balance = self.sellLog.amount
            for log in self.buyLogs {
                balance -= log.amount
            }
            return balance
        }
    }
    
    internal var profit: Double {
        get {
            var profit = 0.0
            for log in self.buyLogs {
                profit += log.price
            }
            profit -= self.sellLog.price
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
        
        let order = SellOrder(currencyPair: self.sellLog.currencyPair, price: price, amount: amt!, api: self.privateApi)!
        order.excute() { (err, res) in
            if let _ = err {
                cb(err)
            } else {
                order.waitForPromise() { (err, promised) in
                    if promised {
                        let log = TradeLog(order: order)
                        self.buyLogs.append(log)
                        cb(nil)
                    } else {
                        cb(err)
                    }
                }
            }
        }
    }
    
    private let sellLog: TradeLog
    private var buyLogs: [TradeLog]
    private let privateApi: PrivateApi
}