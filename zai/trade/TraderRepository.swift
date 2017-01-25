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
    
    func create(_ name: String, exchange: Exchange) -> Trader? {
        let db = Database.getDb()
        
        let newTrader = NSEntityDescription.insertNewObject(forEntityName: TraderRepository.traderModelName, into: db.managedObjectContext) as! Trader
        newTrader.name = name
        newTrader.exchange = exchange
        newTrader.fund = Fund(api: exchange.api)
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
        
        db.saveContext()
        
        return newTrader
    }
    
    func delete(_ trader: Trader) {
        let db = Database.getDb()
        db.managedObjectContext.delete(trader)
        db.saveContext()
    }
    
    func findTraderByName(_ name: String) -> Trader? {
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
                trader.fund = Fund(api: trader.exchange.api)
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
                
                // start monitoring active orders to be promised or delete invalid orders
                let positions = getAccount()!.activeExchange.trader.activePositions
                for position in positions {
                    guard let order = position.order else {
                        continue
                    }
                    if order.orderId == nil || !order.isActive {
                        OrderRepository.getInstance().delete(order)
                        position.order = nil
                        position.open()
                    }
                }
                
                return trader
            }
        } catch {
            return nil
        }
    }
    
    func getAllTraders() -> [Trader] {
        let query: NSFetchRequest<Trader> = Trader.fetchRequest()
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.fetch(query)
            return traders
        } catch {
            return []
        }
    }
    
    func count() -> Int {
        let query: NSFetchRequest<Trader> = Trader.fetchRequest()
        
        let db = Database.getDb()
        do {
            let traders = try db.managedObjectContext.fetch(query)
            return traders.count
        } catch {
            return 0
        }
    }
    
    lazy var traderDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: TraderRepository.traderModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: TraderRepository? = nil
    fileprivate static let traderModelName = "Trader"
}
