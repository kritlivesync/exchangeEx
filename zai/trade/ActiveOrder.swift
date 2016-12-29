//
//  ActiveOrder.swift
//  zai
//
//  Created by 渡部郷太 on 12/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


protocol ActiveOrderDelegate : MonitorableDelegate {
    func revievedActiveOrders(activeOrders: [String: ActiveOrder])
}


struct ActiveOrder {
    init(id: String, action: String, currencyPair: CurrencyPair, price: Double, amount: Double, timestamp: Int64) {
        self.id = id
        self.action = action
        self.price = price
        self.amount = amount
        self.timestamp = timestamp
        self.currencyPair = currencyPair
    }
    
    let id: String
    let action: String
    let currencyPair: CurrencyPair
    let price: Double
    let amount: Double
    let timestamp: Int64
}

class ActiveOrderMonitor : Monitorable {
    
    init(currencyPair: CurrencyPair, api: PrivateApi) {
        self.currencyPair = currencyPair
        self.api = api
    }
    
    override func monitor() {
        let delegate = self.delegate as? ActiveOrderDelegate
        self.api.activeOrders(self.currencyPair) { (err, res) in
            if err != nil {
                return
            }
            if res!["success"].intValue != 1 {
                return
            }
            var activeOrders = [String: ActiveOrder]()
            for (id, order) in res!["return"].dictionaryValue {
                let action = order["action"].stringValue
                let price = order["price"].doubleValue
                let amount = order["amount"].doubleValue
                let timestamp = order["timestamp"].int64Value
                let activeOrder = ActiveOrder(id: id, action: action, currencyPair: self.currencyPair, price: price, amount: amount, timestamp: timestamp)
                activeOrders[id] = activeOrder
            }
            delegate?.revievedActiveOrders(activeOrders: activeOrders)
        }
    }
    
    let currencyPair: CurrencyPair
    let api: PrivateApi
}
