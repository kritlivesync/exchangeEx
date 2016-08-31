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
    
    func createLongPosition(order: BuyOrder, trader: Trader) -> LongPosition? {
        let db = Database.getDb()
        
        if !order.isPromised {
            return nil
        }
        
        let newPosition = NSEntityDescription.insertNewObjectForEntityForName(PositionRepository.longPositionModelName, inManagedObjectContext: db.managedObjectContext) as! LongPosition
        
        
        newPosition.id = NSUUID().UUIDString
        newPosition.trader = trader
        newPosition.buyLog = TradeLog(action: .OPEN_LONG_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: newPosition.id)
        newPosition.sellLogs = []
        
        db.saveContext()
        
        return newPosition
    }
    
    func deleteLongPosition(position: LongPosition) {
        let db = Database.getDb()
        db.managedObjectContext.deleteObject(position)
        db.saveContext()
    }
    
    func createShortPosition(order: SellOrder, trader: Trader) -> ShortPosition? {
        let db = Database.getDb()
        
        if !order.isPromised {
            return nil
        }
        
        let newPosition = NSEntityDescription.insertNewObjectForEntityForName(PositionRepository.shortPositionModelName, inManagedObjectContext: db.managedObjectContext) as! ShortPosition
        
        
        newPosition.id = NSUUID().UUIDString
        newPosition.trader = trader
        newPosition.sellLog = TradeLog(action: .OPEN_SHORT_POSITION, traderName: trader.name, account: trader.account, order: order, positionId: newPosition.id)
        newPosition.buyLogs = []
        
        db.saveContext()
        
        return newPosition
    }
    
    func deleteShoetPosition(position: ShortPosition) {
        let db = Database.getDb()
        db.managedObjectContext.deleteObject(position)
        db.saveContext()
    }
    
    lazy var longPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(PositionRepository.longPositionModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    lazy var shortPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(PositionRepository.shortPositionModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    private init() {
    }
    
    private static var inst: PositionRepository? = nil
    private static let longPositionModelName = "LongPosition"
    private static let shortPositionModelName = "ShortPosition"
}