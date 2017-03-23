//
//  Trader.swift
//  
//
//  Created by Kyota Watanabe on 8/23/16.
//
//

import Foundation
import CoreData

import ZaifSwift


public enum TraderState : String {
    case ACTIVE = "active"
    case IDLE = "idle"
}


open class Trader: NSManagedObject, FundDelegate {
    
    func addPosition(_ position: Position) {
        self.addToPositions(position)
    }
    
    func createLongPosition(_ currencyPair: ApiCurrencyPair, price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?) -> Void) {
        var amt = amount
        if let p = price {
            let maxAmount = Double(self.jpyAvalilable) / p
            amt = min(maxAmount, amt)
        }
        let limit = getAppConfig().buyAmountLimitBtcValue
        amt = min(limit, amt)
        
        let order = OrderRepository.getInstance().createBuyOrder(currencyPair: currencyPair, price: price, amount: amt, api: self.exchange.api)
        order.excute() { (err, orderId) in
            DispatchQueue.main.async {
                if let e = err {
                    OrderRepository.getInstance().delete(order)
                    cb(e, nil)
                } else {
                    let position = PositionRepository.getInstance().createLongPosition(trader: self)
                    cb(nil, position)
                    position.order = order
                    self.addPosition(position)
                }
            }
        }
    }
    
    func unwindPosition(id: String, price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        guard let position = self.getPosition(id: id) else {
            cb(ZaiError(errorType: .INVALID_POSITION), nil, 0.0)
            return
        }
        
        let balance = position.balance
        let btcFundAmount = self.btcAvailable
        let amt = min(min(balance, amount), btcFundAmount)
        if amt < self.exchange.api.orderUnit(currencyPair: position.currencyPair) {
            cb(nil, position, amt)
            position.close()
            position.delegate?.closedPosition(position: position, promisedOrder: nil)
        } else {
            position.unwind(amt, price: price) { (err, orderedAmount) in
                cb(err, position, amt)
            }
        }
    }
    
    func cancelAllOrders() {
        for order in self.activeOrders {
            order.cancel() { _ in }
        }
    }
    
    func unwindAllPositions(price: Double?, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        for position in self.openPositions {
            let balance = position.balance
            self.unwindPosition(id: position.id, price: price, amount: balance, cb: cb)
        }
    }
    
    func ruledUnwindPosition(price: Double?, amount: Double, marketPrice: Double, rule: UnwindingRule, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        
        switch rule {
        case .mostBenefit:
            self.unwindMaxProfitPosition(price: price, amount: amount, marketPrice: marketPrice, cb: cb)
        case .mostLoss:
            self.unwindMaxLossPosition(price: price, amount: amount, marketPrice: marketPrice, cb: cb)
        case .mostRecent:
            self.unwindMostRecentPosition(price: price, amount: amount, cb: cb)
        case .mostOld:
            self.unwindMostOldPosition(price: price, amount: amount, cb: cb)
        }
    }
    
    func unwindMaxProfitPosition(price: Double?, amount: Double, marketPrice: Double, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        guard let position = self.maxUnrealizedProfitPosition(marketPrice: marketPrice) else {
            cb(ZaiError(errorType: .NO_POSITION_TO_UNWIND, message: Resource.noPositionsToUnwind), nil, 0.0)
            return
        }
        self.unwindPosition(id: position.id, price: price, amount: amount, cb: cb)
    }
    
    func unwindMaxLossPosition(price: Double?, amount: Double, marketPrice: Double, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        guard let position = self.maxUnrealizedLossPosition(marketPrice: marketPrice) else {
            cb(ZaiError(errorType: .NO_POSITION_TO_UNWIND, message: Resource.noPositionsToUnwind), nil, 0.0)
            return
        }
        self.unwindPosition(id: position.id, price: price, amount: amount, cb: cb)
    }
    
    func unwindMostRecentPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        guard let position = self.mostRecentPosition else {
            cb(ZaiError(errorType: .NO_POSITION_TO_UNWIND, message: Resource.noPositionsToUnwind), nil, 0.0)
            return
        }
        self.unwindPosition(id: position.id, price: price, amount: amount, cb: cb)
    }
    
    func unwindMostOldPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?, Double) -> Void) {
        guard let position = self.mostOldPosition else {
            cb(ZaiError(errorType: .NO_POSITION_TO_UNWIND, message: Resource.noPositionsToUnwind), nil, 0.0)
            return
        }
        self.unwindPosition(id: position.id, price: price, amount: amount, cb: cb)
    }
    
    func cancelOrder(id: String, cb: @escaping (ZaiError?) -> Void) {
        var targetOrder: Order? = nil
        for position in self.positions {
            let pos = position as! Position
            if let order = pos.order {
                if order.orderId == id {
                    targetOrder = order
                    break
                }
            }
        }
        guard let order = targetOrder else {
            cb(ZaiError(errorType: .INVALID_ORDER))
            return
        }
        order.cancel() { err in
            if err == nil {
                OrderRepository.getInstance().delete(order)
            }
            cb(err)
        }
    }
    
    func deletePosition(id: String) -> Bool {
        guard let position = self.getPosition(id: id) else {
            return false
        }
        if let id = position.order?.orderId {
            let activeOrder = ActiveOrder(id: id, action: "bid", currencyPair: .BTC_JPY, price: 0.0, amount: 0.0, timestamp: 0)
            self.exchange.api.cancelOrder(order: activeOrder, retryCount: 2) { _ in }
            position.order?.delegate = nil
        }
        position.delete()
        return true
    }
    
    func maxUnrealizedProfitPosition(marketPrice: Double) -> Position? {
        let positions = self.openPositions
        var maxPos: Position? = nil
        var maxProfit = -DBL_MAX
        for position in positions {
            let profit = position.calculateUnrealizedProfit(marketPrice: marketPrice)
            if maxProfit < profit {
                maxPos = position
                maxProfit = profit
            }
        }
        return maxPos
    }
    
    func maxUnrealizedLossPosition(marketPrice: Double) -> Position? {
        let positions = self.openPositions
        var minPos: Position? = nil
        var minProfit = DBL_MAX
        for position in positions {
            let profit = position.calculateUnrealizedProfit(marketPrice: marketPrice)
            if profit < minProfit {
                minPos = position
                minProfit = profit
            }
        }
        return minPos
    }
    
    var activePositions: [Position] {
        var positions = [Position]()
        for position in self.positions {
            let p = position as! Position
            let status = PositionState(rawValue: p.status.intValue)
            if (status?.isActive)! {
                positions.append(p)
            }
        }
        return positions
    }
    
    var openPositions: [Position] {
        var positions = [Position]()
        for position in self.positions {
            let p = position as! Position
            let status = PositionState(rawValue: p.status.intValue)
            if (status?.isOpen)! {
                positions.append(p)
            }
        }
        return positions
    }
    
    var allPositions: [Position] {
        var positions = [Position]()
        for position in self.positions {
            positions.append(position as! Position)
        }
        return positions
    }
    
    var sortedPositions: [Position] {
        var opens = [Position]()
        var closeds = [Position]()
        var openings = [Position]()
        var unwindings = [Position]()
        for position in self.positions {
            let p = position as! Position
            let status = PositionState(rawValue: p.status.intValue)!
            switch status {
            case .OPEN:
                opens.append(p)
            case .CLOSED:
                closeds.append(p)
            case .OPENING:
                openings.append(p)
            case .UNWINDING:
                unwindings.append(p)
            default: break
            }
        }
        return opens + unwindings + openings + closeds
    }
    
    var activeOrders: [Order] {
        var orders = [Order]()
        for position in self.positions {
            let p = position as! Position
            if let order = p.order {
                order.api = self.exchange.api
                orders.append(order)
            }
        }
        return orders
    }
    
    var maxProfitPosition: Position? {
        let positions = self.openPositions
        var maxPos: Position? = nil
        var maxProfit = -DBL_MAX
        for position in positions {
            let profit = position.profit
            if maxProfit < profit {
                maxPos = position
                maxProfit = profit
            }
        }
        return maxPos
    }
    
    var maxLossPosition: Position? {
        let positions = self.openPositions
        var minPos: Position? = nil
        var minProfit = DBL_MAX
        for position in positions {
            let profit = position.profit
            if profit < minProfit {
                minPos = position
                minProfit = profit
            }
        }
        return minPos
    }
    
    var mostRecentPosition: Position? {
        let positions = self.openPositions
        var recentPos: Position? = nil
        var recentDate = -LLONG_MAX
        for position in positions {
            let date = position.timestamp
            if recentDate < date {
                recentPos = position
                recentDate = date
            }
        }
        return recentPos
    }
    
    var mostOldPosition: Position? {
        let positions = self.openPositions
        var oldPos: Position? = nil
        var oldDate = LLONG_MAX
        for position in positions {
            let date = position.timestamp
            if date < oldDate {
                oldPos = position
                oldDate = date
            }
        }
        return oldPos
    }
    
    var totalProfit: Double {
        var profit = 0.0
        for position in self.positions {
            let pos = position as! Position
            profit += pos.profit
        }
        return profit
    }
    
    var priceAverage: Double {
        let positions = self.activePositions
        if positions.count == 0 {
            return 0.0
        }
        var cost = 0.0
        var totalAmount = 0.0
        for position in positions {
            let prc = position.price
            let amt = position.amount
            cost += prc * amt
            totalAmount += amt
            
        }
        if totalAmount <= BitCoin.Satoshi {
            return 0.0
        } else {
            return cost / totalAmount
        }
    }
    
    func startWatch() {
        self.stopWatch()
        let api = self.exchange.api
        self.fund = Fund(api: api)
        self.fund.delegate = self
    }
    
    func stopWatch() {
        if self.fund != nil {
            self.fund.delegate = nil
            self.fund = nil
        }
    }
    
    func fixPositionsWithInvalidOrder() {
        let positions = self.activePositions
        let orderUnit = self.exchange.api.orderUnit(currencyPair: self.exchange.apiCurrencyPair)
        for position in positions {
            guard let order = position.order else {
                switch position.status.intValue {
                case PositionState.OPENING.rawValue, PositionState.UNWINDING.rawValue:
                    // ordering status, but has no valid Order
                    if position.balance >= orderUnit {
                        position.open()
                    } else {
                        position.delete()
                    }
                default: break
                }
                continue
            }

            if order.orderId == nil || !order.isActive {
                // has invalid order
                OrderRepository.getInstance().delete(order)
                position.order = nil
                if position.balance >= orderUnit {
                    position.open()
                } else {
                    position.delete()
                }
            }
        }
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "Trader"
    }
    
    // FundDelegate
    func recievedBtcFund(btc: Double, available: Double) {
        self.btcAvailable = available
    }
    
    func recievedJpyFund(jpy: Int, available: Int) {
        self.jpyAvalilable = available
    }
    
    fileprivate func getPosition(id: String) -> Position? {
        for pos in self.positions {
            let p = pos as! Position
            if p.id == id {
                return p
            }
        }
        return nil
    }
    
    var fund: Fund! = nil
    var btcAvailable: Double = 0.0
    var jpyAvalilable: Int = 0
}
