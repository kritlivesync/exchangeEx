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
    
    func create(name: String, account: Account) -> Trader {
        let db = Database.getDb()
        
        let newTrader = NSEntityDescription.insertNewObjectForEntityForName(TraderRepository.traderModelName, inManagedObjectContext: db.managedObjectContext) as! Trader
        newTrader.name = name
        newTrader.account = account
        newTrader.account = account
        
        db.saveContext()
        
        return newTrader
    }
    
    func delete(trader: Trader) {
        let db = Database.getDb()
        db.managedObjectContext.deleteObject(trader)
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
                let trader = traders[0]
                trader.account.privateApi = api
                return trader
            }
        } catch {
            return nil
        }
    }
    
    func getAllTraders(api: PrivateApi) -> [Trader] {
        let query = NSFetchRequest(entityName: TraderRepository.traderModelName)
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.executeFetchRequest(query) as! [Trader]
            for trader in traders {
                trader.account.privateApi = api
            }
            return traders
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
    
    lazy var longPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(TraderRepository.longPositionModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    lazy var shortPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entityForName(TraderRepository.shortPositionModelName, inManagedObjectContext: db.managedObjectContext)!
    }()
    
    private init() {
    }
    
    private static var inst: TraderRepository? = nil
    private static let traderModelName = "Trader"
    private static let longPositionModelName = "LongPosition"
    private static let shortPositionModelName = "ShortPosition"
}