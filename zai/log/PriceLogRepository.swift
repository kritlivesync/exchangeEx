//
//  PriceLogRepository.swift
//  zai
//
//  Created by 渡部郷太 on 9/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import CoreData


class PriceLogRepository {
    
    static func getInstance() -> PriceLogRepository {
        if let inst = PriceLogRepository.inst {
            return inst
        } else {
            let inst = PriceLogRepository()
            PriceLogRepository.inst = inst
            return inst
        }
    }
    
    func create(currencyPair: String, price: Double) -> TradeLog {
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObjectForEntityForName(PriceLogRepository.priceLogModelName, inManagedObjectContext: db.managedObjectContext) as! TradeLog

        newLog.price = price
        newLog.currencyPair = currencyPair
        newLog.timestamp = NSDate().timeIntervalSince1970
        
        db.saveContext()
        
        return newLog
    }
    
    lazy var tradeLogDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(PriceLogRepository.priceLogModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    private init() {
    }
    
    private static var inst: PriceLogRepository? = nil
    private static let priceLogModelName = "PriceLog"
}