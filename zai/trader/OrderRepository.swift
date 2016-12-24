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
        
        order.zaifOrder = order.createOrder(currencyPair, price: price, amount: amount)
        
        order.promiseMonitorTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: order,
            selector: #selector(Order.monitor),
            userInfo: nil,
            repeats: true)
    }
    
    fileprivate init() {
    }
    
    fileprivate static var inst: OrderRepository? = nil
    fileprivate static let buyOrderModelName = "BuyOrder"
    fileprivate static let sellOrderModelName = "SellOrder"
}

