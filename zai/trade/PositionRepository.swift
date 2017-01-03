//
//  TraderRepository.swift
//  zai
//
//  Created by 渡部郷太 on 8/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import CoreData

import ZaifSwift


class PositionRepository {
    
    static func getInstance() -> PositionRepository {
        if let inst = PositionRepository.inst {
            return inst
        } else {
            let inst = PositionRepository()
            PositionRepository.inst = inst
            return inst
        }
    }
    
    func createLongPosition(trader: Trader, id: String?=nil) -> LongPosition {
        let db = Database.getDb()
        
        let newPosition = NSEntityDescription.insertNewObject(forEntityName: PositionRepository.longPositionModelName, into: db.managedObjectContext) as! LongPosition
        
        newPosition.id = (id == nil) ? UUID().uuidString : id!
        newPosition.trader = trader
        newPosition.status = NSNumber(value: PositionState.OPENING.rawValue)

        db.saveContext()
        return newPosition
    }
    
    func deleteLongPosition(_ position: LongPosition) {
        let db = Database.getDb()
        db.managedObjectContext.delete(position)
        db.saveContext()
    }
    
    func createShortPosition(_ order: SellOrder, trader: Trader) -> ShortPosition {
        let db = Database.getDb()

        let newPosition = NSEntityDescription.insertNewObject(forEntityName: PositionRepository.shortPositionModelName, into: db.managedObjectContext) as! ShortPosition
        
        
        newPosition.id = UUID().uuidString
        newPosition.trader = trader
        
        let log = TradeLogRepository.getInstance().create(.OPEN_SHORT_POSITION, traderName: trader.name, account: trader.exchange.account, order: order, positionId: newPosition.id)
        newPosition.addLog(log)
        
        db.saveContext()
        
        return newPosition
    }
    
    func deleteShortPosition(_ position: ShortPosition) {
        let db = Database.getDb()
        db.managedObjectContext.delete(position)
        db.saveContext()
    }
    
    lazy var longPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: PositionRepository.longPositionModelName, in: db.managedObjectContext)!
    }()
    
    lazy var shortPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: PositionRepository.shortPositionModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: PositionRepository? = nil
    fileprivate static let longPositionModelName = "LongPosition"
    fileprivate static let shortPositionModelName = "ShortPosition"
}
