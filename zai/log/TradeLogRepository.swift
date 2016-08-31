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
    
    func create(action: TradeAction, traderName: String, account: Account, order: Order, positionId: String) -> TradeLog {
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObjectForEntityForName(TradeLogRepository.tradeLogModelName, inManagedObjectContext: db.managedObjectContext) as! TradeLog
        newLog.id = NSUUID().UUIDString
        newLog.userId = account.userId
        newLog.apiKey = account.privateApi.apiKey
        newLog.positionId = positionId
        newLog.traderName = traderName
        newLog.tradeAction = action.rawValue
        newLog.orderAction = order.action.rawValue
        newLog.orderId = order.orderId
        newLog.currencyPair = order.currencyPair.rawValue
        newLog.price = order.price
        newLog.amount = order.amount
        newLog.timestamp = NSDate().timeIntervalSince1970
        
        db.saveContext()
        
        return newLog
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