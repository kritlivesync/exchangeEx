//
//  TradeLog.swift
//  zai
//
//  Created by 渡部郷太 on 8/20/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal class TradeLog {
    init(order: Order) {
        self.currencyPair = order.currencyPair
        self.action = order.action
        self.price = order.price
        self.amount = order.amount
        self.timestamp = order.promisedTime
    }
    
    internal let currencyPair: CurrencyPair
    internal let action: OrderAction
    internal let price: Double
    internal let amount: Double
    internal let timestamp: Int64
}