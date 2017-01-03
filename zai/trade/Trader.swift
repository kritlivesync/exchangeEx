//
//  Trader.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
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
        let positions = self.mutableOrderedSetValue(forKey: "positions")
        positions.add(position)
        Database.getDb().saveContext()
    }
    
    func createLongPosition(_ currencyPair: ApiCurrencyPair, price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?) -> Void) {
        var amt = amount
        if let p = price {
            let maxAmount = Double(self.jpyFund) / p
            amt = min(maxAmount, amt)
        }
        let order = OrderRepository.getInstance().createBuyOrder(currencyPair: currencyPair, price: price, amount: amt, api: self.exchange.api)
        order.excute() { (err, orderId) in
            if let e = err {
                cb(e, nil)
            } else {
                let position = PositionRepository.getInstance().createLongPosition(trader: self)
                cb(nil, position)
                position.order = order
                self.addPosition(position)
            }
        }
    }
    
    func unwindPosition(id: String, price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?) -> Void) {
        let position = self.getPosition(id: id)
        if position == nil {
            cb(ZaiError(errorType: .INVALID_POSITION), nil)
            return
        }
        
        let balance = position!.balance
        let btcFundAmount = self.btcFund
        let amt = min(min(balance, amount), btcFundAmount)
        if amt < 0.0001 {
            cb(nil, position)
            position!.close()
            position?.delegate?.closedPosition(position: position!)
        } else {
            position!.unwind(amt, price: price) { err in
                cb(err, position)
            }
        }
    }
    
    func unwindMaxProfitPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?) -> Void) {
        let position = self.maxProfitPosition
        if let pos = position {
            self.unwindPosition(id: pos.id, price: price, amount: amount, cb: cb)
        } else {
            cb(ZaiError(errorType: .INVALID_POSITION), nil)
        }
    }
    
    func unwindMinProfitPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?, Position?) -> Void) {
        let position = self.minProfitPosition
        if let pos = position {
            self.unwindPosition(id: pos.id, price: price, amount: amount, cb: cb)
        } else {
            cb(ZaiError(errorType: .INVALID_POSITION), nil)
        }
    }
    
    func deletePosition(id: String) -> Bool {
        guard let position = self.getPosition(id: id) else {
            return false
        }
        let positions = self.mutableOrderedSetValue(forKey: "positions")
        positions.remove(position)
        position.delete()
        return true
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
            let p = position as! Position
            positions.append(p)
        }
        return positions
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
    
    var minProfitPosition: Position? {
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
        if totalAmount <= 0.000000001 {
            return 0.0
        } else {
            return cost / totalAmount
        }
    }
    
    // FundDelegate
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
    }
    
    func recievedJpyFund(jpy: Int) {
        self.jpyFund = jpy
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
    var btcFund: Double = 0.0
    var jpyFund: Int = 0
}
