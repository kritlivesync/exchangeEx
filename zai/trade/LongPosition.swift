//
//  LongPosition.swift
//  
//
//  Created by Kyota Watanabe on 8/31/16.
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
    
    override func unwind(_ amount: Double?=nil, price: Double?, cb: @escaping (ZaiError?, Double) -> Void) {
        let state = PositionState(rawValue: self.status.intValue)
        if state != PositionState.OPEN {
            cb(nil, 0.0)
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
            DispatchQueue.main.async {
                if let e = err {
                    OrderRepository.getInstance().delete(order)
                    self.open()
                    cb(e, amt!)
                } else {
                    cb(nil, amt!)
                    self.order = order
                }
            }
        }
    }
    
    // OrderDelegate
    override func orderPromised(order: Order, promisedOrder: PromisedOrder) {
        DispatchQueue.main.async {
            self.order = nil
            switch self.status.intValue {
            case PositionState.OPENING.rawValue:
                let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                
                self.addLog(log)
                self.open()
                self.delegate?.opendPosition(position: self, promisedOrder: promisedOrder)
                self.delegate2?.opendPosition(position: self, promisedOrder: promisedOrder)
            case PositionState.UNWINDING.rawValue:
                let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                self.addLog(log)
                if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                    self.close()
                    self.delegate?.closedPosition(position: self, promisedOrder: promisedOrder)
                    self.delegate2?.closedPosition(position: self, promisedOrder: promisedOrder)
                } else {
                    self.open()
                    self.delegate?.unwindPosition(position: self, promisedOrder: promisedOrder)
                    self.delegate2?.unwindPosition(position: self, promisedOrder: promisedOrder)
                }
            case PositionState.PARTIAL.rawValue:
                if order.action == "bid" {
                    let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                    
                    self.addLog(log)
                    self.open()
                    self.delegate?.opendPosition(position: self, promisedOrder: promisedOrder)
                    self.delegate2?.opendPosition(position: self, promisedOrder: promisedOrder)
                } else if order.action == "ask" {
                    let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                    self.addLog(log)
                    if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                        self.close()
                        self.delegate?.closedPosition(position: self, promisedOrder: promisedOrder)
                        self.delegate2?.closedPosition(position: self, promisedOrder: promisedOrder)
                    } else {
                        self.open()
                        self.delegate?.unwindPosition(position: self, promisedOrder: promisedOrder)
                        self.delegate2?.unwindPosition(position: self, promisedOrder: promisedOrder)
                    }
                }
            default: break
            }
        }
    }
    
    override func orderPartiallyPromised(order: Order, promisedOrder: PromisedOrder) {
        DispatchQueue.main.async {
            switch self.status.intValue {
            case PositionState.OPENING.rawValue:
                let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                self.addLog(log)
                self.partial()
            case PositionState.UNWINDING.rawValue:
                let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                self.addLog(log)
                self.partial()
            case PositionState.PARTIAL.rawValue:
                if order.action == "bid" {
                    let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                    self.addLog(log)
                    self.partial()
                } else if order.action == "ask" {
                    let log = TradeLogRepository.getInstance().create(userId: self.trader!.exchange.account.userId, action: .UNWIND_LONG_POSITION, traderName: self.trader!.name, orderAction: order.action, orderId: order.orderId!, currencyPair: order.currencyPair, price: promisedOrder.price, amount: promisedOrder.newlyPromisedAmount, positionId: self.id)
                    self.addLog(log)
                    self.partial()
                }
            default: break
            }
        }
    }
    
    override func orderCancelled(order: Order) {
        DispatchQueue.main.async {
            self.order = nil
            switch self.status.intValue {
            case PositionState.OPENING.rawValue:
                guard let orderId = order.orderId else {
                    return
                }
                guard let trader = self.trader else {
                    return
                }
                let log = TradeLogRepository.getInstance().create(userId: trader.exchange.account.userId, action: .CANCEL, traderName: trader.name, orderAction: order.action, orderId: orderId, currencyPair: order.currencyPair, price: order.orderPrice?.doubleValue, amount: Double(order.orderAmount), positionId: self.id)
                self.addLog(log)
                if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                    self.delete()
                } else {
                    self.open()
                }
            case PositionState.PARTIAL.rawValue:
                guard let orderId = order.orderId else {
                    return
                }
                guard let trader = self.trader else {
                    return
                }
                let log = TradeLogRepository.getInstance().create(userId: trader.exchange.account.userId, action: .CANCEL, traderName: trader.name, orderAction: order.action, orderId: orderId, currencyPair: order.currencyPair, price: order.orderPrice?.doubleValue, amount: Double(order.orderAmount), positionId: self.id)
                self.addLog(log)
                if self.balance < self.trader!.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                    self.delete()
                } else {
                    self.open()
                }
            case PositionState.UNWINDING.rawValue:
                guard let trader = self.trader else {
                    return
                }
                if self.balance < trader.exchange.api.orderUnit(currencyPair: self.currencyPair) {
                    self.close()
                    self.delegate?.closedPosition(position: self, promisedOrder: nil)
                    self.delegate2?.closedPosition(position: self, promisedOrder: nil)
                } else {
                    self.open()
                }
            default: break
            }
        }
    }
    
}
