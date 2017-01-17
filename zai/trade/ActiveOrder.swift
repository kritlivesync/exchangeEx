//
//  ActiveOrder.swift
//  zai
//
//  Created by 渡部郷太 on 12/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


protocol ActiveOrderDelegate : MonitorableDelegate {
    func revievedActiveOrders(activeOrders: [String: ActiveOrder])
}


struct ActiveOrder {
    init(id: String, action: String, currencyPair: ApiCurrencyPair, price: Double, amount: Double, timestamp: Int64) {
        self.id = id
        self.action = action
        self.price = price
        self.amount = amount
        self.timestamp = timestamp
        self.currencyPair = currencyPair
    }
    
    let id: String
    let action: String
    let currencyPair: ApiCurrencyPair
    let price: Double
    let amount: Double
    let timestamp: Int64
}

class ActiveOrderMonitor : Monitorable {
    
    init(currencyPair: ApiCurrencyPair, api: Api) {
        self.currencyPair = currencyPair
        self.api = api
        super.init(target: "Order")
    }
    
    override func monitor() {
        let delegate = self.delegate as? ActiveOrderDelegate
        self.api.getActiveOrders(currencyPair: self.currencyPair) { (err, orders) in
            if err == nil {
                delegate?.revievedActiveOrders(activeOrders: orders)
            }
        }
    }
    
    let currencyPair: ApiCurrencyPair
    let api: Api
}
