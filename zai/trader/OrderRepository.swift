//
//  OrderRepository.swift
//  zai
//
//  Created by 渡部郷太 on 12/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import CoreData

import ZaifSwift


class OrderRepository {
    
    static func getInstance() -> OrderRepository {
        if let inst = OrderRepository.inst {
            return inst
        } else {
            let inst = OrderRepository()
            OrderRepository.inst = inst
            return inst
        }
    }
    
    func createBuyOrder(currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) -> BuyOrder {
        let db = Database.getDb()
        
        var newOrder = NSEntityDescription.insertNewObject(forEntityName: OrderRepository.buyOrderModelName, into: db.managedObjectContext) as! Order
        
        self.buildOrder(order: &newOrder, action: OrderAction.BID.rawValue, currencyPair: currencyPair, price: price, amount: amount, api: api)
        
        db.saveContext()
        
        return newOrder as! BuyOrder
    }
    
    func createSellOrder(currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) -> SellOrder {
        let db = Database.getDb()
        
        var newOrder = NSEntityDescription.insertNewObject(forEntityName: OrderRepository.sellOrderModelName, into: db.managedObjectContext) as! Order
        
        self.buildOrder(order: &newOrder, action: OrderAction.ASK.rawValue, currencyPair: currencyPair, price: price, amount: amount, api: api)
        
        db.saveContext()
        
        return newOrder as! SellOrder
    }
    
    func findBuyOrderByOrderId(orderId: String, api: PrivateApi) -> BuyOrder? {
        let query: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: OrderRepository.buyOrderModelName)
        let predicate = NSPredicate(format: "orderId = %@", orderId)
        query.predicate = predicate
        return self.findOrder(query: query, api: api) as? BuyOrder
    }
    
    func findSellOrderByOrderId(orderId: String, api: PrivateApi) -> SellOrder? {
        let query: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: OrderRepository.sellOrderModelName)
        let predicate = NSPredicate(format: "orderId = %@", orderId)
        query.predicate = predicate
        return self.findOrder(query: query, api: api) as? SellOrder
    }
    
    func delete(_ order: Order) {
        let db = Database.getDb()
        db.managedObjectContext.delete(order)
        db.saveContext()
    }
    
    lazy var buyOrderDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: OrderRepository.buyOrderModelName, in: db.managedObjectContext)!
    }()
    
    lazy var traderDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: OrderRepository.sellOrderModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate func findOrder(query: NSFetchRequest<NSFetchRequestResult>, api: PrivateApi) -> Order? {
        let db = Database.getDb()
        do {
            let orders = try db.managedObjectContext.fetch(query) as! [Order]
            if orders.count != 1 {
                return nil
            } else {
                let order = orders[0]
                let cp = CurrencyPair(rawValue: order.currencyPair)!
                order.zaifOrder = order.createOrder(cp, price: order.orderPrice as Double?, amount: Double(order.orderAmount))
                order.activeOrderMonitor = ActiveOrderMonitor(currencyPair: cp, api: api)
                order.activeOrderMonitor?.delegate = order
                return order
            }
        } catch {
            return nil
        }
    }
    
    fileprivate func buildOrder(order: inout Order, action: String, currencyPair: CurrencyPair, price: Double?, amount: Double, api: PrivateApi) {
    
        order.id = UUID().uuidString
        order.status = NSNumber(value: OrderState.WAITING.rawValue)
        order.action = action
        order.promisedTime = 0
        order.promisedPrice = 0.0
        order.promisedAmount = 0.0
        order.privateApi = api
        order.orderPrice = price as NSNumber?
        order.orderAmount = (amount as NSNumber?)!
        order.currencyPair = currencyPair.rawValue
        order.zaifOrder = order.createOrder(currencyPair, price: price, amount: amount)
        order.activeOrderMonitor = ActiveOrderMonitor(currencyPair: currencyPair, api: api)
        order.activeOrderMonitor?.delegate = order
    }
    
    fileprivate init() {
    }
    
    fileprivate static var inst: OrderRepository? = nil
    fileprivate static let buyOrderModelName = "BuyOrder"
    fileprivate static let sellOrderModelName = "SellOrder"
}

