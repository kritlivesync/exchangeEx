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
    
    override func close() {
        let balance = self.balance
        if BitCoin.Satoshi <= balance {
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: "ask", orderId: "", currencyPair: self.currencyPair.rawValue, price: 0.0, amount: balance, positionId: self.id)
            self.addLog(log)
        }
        super.close()
    }
    
    override func calculateUnrealizedProfit(marketPrice: Double) -> Double {
        return self.profit + (marketPrice - self.price) * self.balance
    }
    
    override public var price: Double {
        get {
            var prc = 0.0
            let totalAmount = self.amount

            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION || action == .EDIT_PRICE {
                    let ratio = l.amount!.doubleValue / totalAmount
                    prc += l.price!.doubleValue * ratio
                }
            }
            return prc
        }
        set {
            let oldValue = self.price
            let diffValue = Double(newValue) - oldValue
            if abs(diffValue) <= BitCoin.Satoshi {
                return
            }
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .EDIT_PRICE, traderName: self.trader!.name, orderAction: "bid", orderId: nil, currencyPair: self.currencyPair.rawValue, price: diffValue, amount: nil, positionId: self.id)
            self.addLog(log)
        }
    }
    
    override public var amount: Double {
        get {
            var amt = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION || action == .EDIT_AMOUNT {
                    amt += l.amount!.doubleValue
                }
            }
            return amt
        }
        set {
            let oldValue = self.amount
            let diffValue = Double(newValue) - oldValue
            if abs(diffValue) <= BitCoin.Satoshi {
                return
            }
            let price = self.price
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .EDIT_AMOUNT, traderName: self.trader!.name, orderAction: "bid", orderId: nil, currencyPair: self.currencyPair.rawValue, price: price, amount: diffValue, positionId: self.id)
            self.addLog(log)
        }
    }
    
    override internal var balance: Double {
        get {
            var balance = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    balance += l.amount!.doubleValue
                } else if action == .UNWIND_LONG_POSITION {
                    balance -= l.amount!.doubleValue
                }
            }
            return balance
        }
    }
    
    override internal var profit: Double {
        get {
            let buyPrice = self.price
            var sellPriceSum = 0.0
            var sellAmount = 0.0
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .UNWIND_LONG_POSITION {
                    if 0.0 < l.price!.doubleValue {
                        sellAmount += l.amount!.doubleValue
                        sellPriceSum += l.price!.doubleValue * l.amount!.doubleValue
                    }
                }
            }
            return sellPriceSum - (buyPrice * sellAmount)
        }
    }
    
    override internal var currencyPair: ApiCurrencyPair {
        get {
            var currencyPair = ApiCurrencyPair.BTC_JPY
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    currencyPair = ApiCurrencyPair(rawValue: l.currencyPair!)!
                    break
                }
            }
            return currencyPair
        }
    }
    
    override internal var type: String {
        get {
            return "long"
        }
    }
    
    override var timestamp: Int64 {
        get {
            for log in self.tradeLogs {
                let l = log as! TradeLog
                let action = TradeAction(rawValue: l.tradeAction)
                if action == .OPEN_LONG_POSITION {
                    return l.timestamp.int64Value
                }
            }
            return 0
        }
    }
    
    override func unwind(_ amount: Double?=nil, price: Double?, cb: @escaping (ZaiError?) -> Void) {
        let state = PositionState(rawValue: self.status.intValue)
        if state != PositionState.OPEN {
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
        
        print("sell: " + amt!.description)
        
        let order = OrderRepository.getInstance().createSellOrder(currencyPair: self.currencyPair, price: price, amount: amt!, api: self.trader!.exchange.api)
        
        order.excute() { (err, _) in
            cb(err)
            self.order = order
        }
    }
    
    // OrderDelegate
    override func orderPromised(order: Order, price: Double, amount: Double) {
        self.order = nil
        switch self.status.intValue {
        case PositionState.OPENING.rawValue:
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: price, amount: amount, positionId: self.id)

            self.addLog(log)
            self.open()
            self.delegate?.opendPosition(position: self)
        case PositionState.UNWINDING.rawValue:
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: price, amount: amount, positionId: self.id)
            self.addLog(log)
            if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                self.close()
                self.delegate?.closedPosition(position: self)
            } else {
                self.open()
                self.delegate?.unwindPosition(position: self)
            }
        default: break
        }
    }
    
    override func orderPartiallyPromised(order: Order, price: Double, amount: Double) {
        switch self.status.intValue {
        case PositionState.OPENING.rawValue:
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: price, amount: amount, positionId: self.id)
            self.addLog(log)
        case PositionState.UNWINDING.rawValue:
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: price, amount: amount, positionId: self.id)
            self.addLog(log)
        default: break
        }
    }
    
    override func orderCancelled(order: Order) {
        self.order = nil
        switch self.status.intValue {
        case PositionState.OPENING.rawValue:
            let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .CANCEL, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: price, amount: Double(order.orderAmount), positionId: self.id)
            self.addLog(log)
            if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                self.delete()
            } else {
                self.open()
            }
        case PositionState.UNWINDING.rawValue:
            if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                self.close()
                self.delegate?.closedPosition(position: self)
            } else {
                self.open()
            }
        default: break
        }
    }
    
}
