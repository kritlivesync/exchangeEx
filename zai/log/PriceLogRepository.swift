//
//  PriceLogRepository.swift
//  zai
//
//  Created by Kyota Watanabe on 9/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
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
    
    func create(_ currencyPair: String, price: Double) -> TradeLog {
        let db = Database.getDb()
        
        let newLog = NSEntityDescription.insertNewObject(forEntityName: PriceLogRepository.priceLogModelName, into: db.managedObjectContext) as! TradeLog

        newLog.price = NSNumber(value: price)
        newLog.currencyPair = currencyPair
        newLog.timestamp = NSNumber(value: Date().timeIntervalSince1970)
        
        db.saveContext()
        
        return newLog
    }
    
    lazy var tradeLogDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: PriceLogRepository.priceLogModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: PriceLogRepository? = nil
    fileprivate static let priceLogModelName = "PriceLog"
}
