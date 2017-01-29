//
//  TradeLogRepository.swift
//  zai
//
//  Created by Kyota Watanabe on 8/23/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import CoreData

import ZaifSwift


class TradeLogRepository {
    
    static func getInstance() -> TradeLogRepository {
        if let inst = TradeLogRepository.inst {
            return inst
        } else {
            let inst = TradeLogRepository()
            TradeLogRepository.inst = inst
            return inst
        }
    }
    
    func create(userId: String, action: TradeAction, traderName: String, orderAction: String?, orderId: String?, currencyPair: String?, price: Double?, amount: Double?, positionId: String?) -> TradeLog {
        
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObject(forEntityName: TradeLogRepository.tradeLogModelName, into: db.managedObjectContext) as! TradeLog
        newLog.id = UUID().uuidString
        newLog.userId = userId
        newLog.positionId = positionId
        newLog.traderName = traderName
        newLog.tradeAction = action.rawValue
        newLog.orderAction = orderAction
        newLog.orderId = orderId
        newLog.currencyPair = currencyPair
        if let p = price {
            newLog.price = NSNumber(value: p)
        }
        newLog.amount = amount as NSNumber?
        newLog.timestamp = NSNumber(value: Date().timeIntervalSince1970)
        
        db.saveContext()
        
        return newLog
    }
    
    func create(_ action: TradeAction, traderName: String, account: Account, order: Order, positionId: String) -> TradeLog {
        return self.create(userId: account.userId, action: action, traderName: traderName, orderAction: order.action, orderId: order.id, currencyPair: order.currencyPair, price: order.orderPrice as Double?, amount: order.orderAmount as Double?, positionId: positionId)
    }
    
    lazy var tradeLogDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: TradeLogRepository.tradeLogModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: TradeLogRepository? = nil
    fileprivate static let tradeLogModelName = "TradeLog"
}
