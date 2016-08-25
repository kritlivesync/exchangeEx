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
    
    func store(log: TradeLog) {
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObjectForEntityForName(TradeLogRepository.tradeLogModelName, inManagedObjectContext: db.managedObjectContext) as! TradeLog
        newLog.id = log.id
        newLog.userId = log.userId
        newLog.apiKey = log.apiKey
        newLog.positionId = log.positionId
        newLog.traderName = log.traderName
        newLog.tradeAction = log.tradeAction
        newLog.orderAction = log.orderAction
        newLog.currencyPair = log.currencyPair
        newLog.price = log.price
        newLog.amount = log.amount
        newLog.timestamp = log.timestamp
        
        db.saveContext()
    }
    
    lazy var tradeLogDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(TradeLogRepository.tradeLogModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    private init() {
    }
    
    private static var inst: TradeLogRepository? = nil
    private static let tradeLogModelName = "TradeLog"
}