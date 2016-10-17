//
//  TradeLogRepository.swift
//  zai
//
//  Created by 渡部郷太 on 8/23/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import CoreData


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
    
    func create(_ action: TradeAction, traderName: String, account: Account, order: Order, positionId: String) -> TradeLog {
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObject(forEntityName: TradeLogRepository.tradeLogModelName, into: db.managedObjectContext) as! TradeLog
        newLog.id = UUID().uuidString
        newLog.userId = account.userId
        newLog.apiKey = account.privateApi.apiKey
        newLog.positionId = positionId
        newLog.traderName = traderName
        newLog.tradeAction = action.rawValue
        newLog.orderAction = order.action.rawValue
        newLog.orderId = NSNumber(value: order.orderId)
        newLog.currencyPair = order.currencyPair.rawValue
        newLog.price = NSNumber(value: order.price)
        newLog.amount = NSNumber(value: order.amount)
        newLog.timestamp = NSNumber(value: Date().timeIntervalSince1970)
        
        db.saveContext()
        
        return newLog
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
