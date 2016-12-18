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
    
    func create(_ name: String, account: Account) -> Trader {
        let db = Database.getDb()
        
        let newTrader = NSEntityDescription.insertNewObject(forEntityName: TraderRepository.traderModelName, into: db.managedObjectContext) as! Trader
        newTrader.name = name
        newTrader.account = account
        newTrader.fund = Fund(api: account.privateApi)
        newTrader.fund.delegate = newTrader
        newTrader.fund.getBtcFund() { (err, btc) in
            if err == nil {
                newTrader.btcFund = btc
            }
        }
        newTrader.fund.getJpyFund() { (err, jpy) in
            if err == nil {
                newTrader.jpyFund = jpy
            }
        }
        
        //db.saveContext()
        
        return newTrader
    }
    
    func delete(_ trader: Trader) {
        let db = Database.getDb()
        db.managedObjectContext.delete(trader)
        db.saveContext()
    }
    
    func findTraderByName(_ name: String, api: PrivateApi) -> Trader? {
        let query: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: TraderRepository.traderModelName)
        let predicate = NSPredicate(format: "name = %@", name)
        query.predicate = predicate
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.fetch(query) as! [Trader]
            if traders.count != 1 {
                return nil
            } else {
                let trader = traders[0]
                trader.account.privateApi = api
                trader.fund = Fund(api: api)
                trader.fund.delegate = trader
                trader.fund.getBtcFund() { (err, btc) in
                    if err == nil {
                        trader.btcFund = btc
                    }
                }
                trader.fund.getJpyFund() { (err, jpy) in
                    if err == nil {
                        trader.jpyFund = jpy
                    }
                }
                return trader
            }
        } catch {
            return nil
        }
    }
    
    func getAllTraders(_ api: PrivateApi) -> [Trader] {
        let query = Trader.fetchRequest()
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.fetch(query) as! [Trader]
            for trader in traders {
                trader.account.privateApi = api
            }
            return traders
        } catch {
            return []
        }
    }
    
    func count() -> Int {
        let query = Trader.fetchRequest()
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.fetch(query) as! [Trader]
            return traders.count
        } catch {
            return 0
        }
    }
    
    lazy var traderDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: TraderRepository.traderModelName, in: db.managedObjectContext)!
    }()
    
    lazy var longPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: TraderRepository.longPositionModelName, in: db.managedObjectContext)!
    }()
    
    lazy var shortPositionDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: TraderRepository.shortPositionModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: TraderRepository? = nil
    fileprivate static let traderModelName = "Trader"
    fileprivate static let longPositionModelName = "LongPosition"
    fileprivate static let shortPositionModelName = "ShortPosition"
}
