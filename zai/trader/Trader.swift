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

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.fund = Fund(api: account.privateApi)
        self.fund.delegate = self
        self.fund.getBtcFund() { (err, btc) in
            if err == nil {
                self.btcFund = btc
            }
        }
    }
    
    convenience init(name: String, account: Account) {
        self.init(entity: TraderRepository.getInstance().traderDescription, insertInto: nil)
        
        self.name = name
        self.status = TraderState.ACTIVE.rawValue
        self.account = account
        self.positions = []
    }
    
    func addPosition(_ position: Position) {
        let positions = self.mutableOrderedSetValue(forKey: "positions")
        positions.add(position)
        Database.getDb().saveContext()
    }
    
    func createLongPosition(_ currencyPair: CurrencyPair, price: Double?, amount: Double, cb: @escaping (ZaiError?) -> Void) {
        let amt = min(self.btcFund, amount)
        let order = BuyOrder(currencyPair: currencyPair, price: price, amount: amt, api: self.account.privateApi)!
        order.excute() { (err, orderId) in
            if let e = err {
                cb(e)
            } else {
                order.waitForPromise(timeout: 30) { (err, promised) in
                    if let e = err {
                        cb(e)
                    } else {
                        if promised {
                            let position = PositionRepository.getInstance().createLongPosition(order, trader: self)!
                            self.addPosition(position)
                            cb(nil)
                        } else {
                            self.account.privateApi.cancelOrder(order.orderId) { (err, _) in
                                cb(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func unwindPosition(id: String, price: Double?, amount: Double, cb: @escaping (ZaiError?) -> Void) {
        var position: Position? = nil
        for pos in self.activePositions {
            if pos.id == id {
                position = pos
                break
            }
        }
        if position == nil {
            cb(ZaiError(errorType: .INVALID_POSITION))
            return
        }
        
        let balance = position!.balance
        let btcFundAmount = self.btcFund
        let amt = min(min(balance, amount), btcFundAmount)
        if amt < 0.0001 {
            position!.close()
            cb(nil)
        } else {
            position!.unwind(amount, price: price) { err in
                if let _ = err {
                    cb(err)
                } else {
                    if btcFundAmount < balance {
                        position!.close()
                    }
                    cb(nil)
                }
            }
        }
    }
    
    func unwindMaxProfitPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?) -> Void) {
        let position = self.maxProfitPosition
        if let pos = position {
            self.unwindPosition(id: pos.id, price: price, amount: amount, cb: cb)
        } else {
            cb(ZaiError(errorType: .INVALID_POSITION))
        }
    }
    
    func unwindMinProfitPosition(price: Double?, amount: Double, cb: @escaping (ZaiError?) -> Void) {
        let position = self.minProfitPosition
        if let pos = position {
            self.unwindPosition(id: pos.id, price: price, amount: amount, cb: cb)
        } else {
            cb(ZaiError(errorType: .INVALID_POSITION))
        }
    }
    
    var activePositions: [Position] {
        var positions = [Position]()
        for position in self.positions {
            let p = position as! Position
            if p.status.intValue == PositionState.OPEN.rawValue {
                positions.append(p)
            }
        }
        return positions
    }
    
    var maxProfitPosition: Position? {
        let positions = self.activePositions
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
        let positions = self.activePositions
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
    
    // FundDelegate
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
    }
    
    var fund: Fund! = nil
    var btcFund: Double = 0.0
}
