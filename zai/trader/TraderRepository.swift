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


class TraderRepository {
    
    static func getInstance() -> TraderRepository {
        if let inst = TraderRepository.inst {
            return inst
        } else {
            let inst = TraderRepository()
            TraderRepository.inst = inst
            return inst
        }
    }
    
    func register(trader: Trader) {
        let db = Database.getDb()
        
        let newTrader = NSEntityDescription.insertNewObjectForEntityForName(TraderRepository.traderModelName, inManagedObjectContext: db.managedObjectContext) as! Trader
        newTrader.name = trader.name
        let ac = trader.account
        newTrader.account = ac
        newTrader.positions = trader.positions
        
        db.saveContext()
    }
    
    func findTraderByName(name: String, api: PrivateApi) -> Trader? {
        let query = NSFetchRequest(entityName: TraderRepository.traderModelName)
        let predicate = NSPredicate(format: "name = %@", name)
        query.predicate = predicate
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.executeFetchRequest(query) as! [Trader]
            if traders.count != 1 {
                return nil
            } else {
                let dbTrader = traders[0]
                let account = Account(userId: dbTrader.account.userId, api: api)
                return StrongTrader(name: dbTrader.name, account: account)
            }
        } catch {
            return nil
        }
    }
    
    func getAllTraders() -> [Trader] {
        let query = NSFetchRequest(entityName: TraderRepository.traderModelName)
        
        let db = Database.getDb()
        do {
            return try db.managedObjectContext.executeFetchRequest(query) as! [Trader]
        } catch {
            return []
        }
    }
    
    func count() -> Int {
        let query = NSFetchRequest(entityName: TraderRepository.traderModelName)
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.executeFetchRequest(query) as! [Trader]
            return traders.count
        } catch {
            return 0
        }
    }
    
    lazy var traderDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(TraderRepository.traderModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    lazy var positionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(TraderRepository.positionModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    private init() {
    }
    
    private static var inst: TraderRepository? = nil
    private static let traderModelName = "Trader"
    private static let positionModelName = "Trader"
}