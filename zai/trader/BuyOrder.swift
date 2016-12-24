//
//  BuyOrder+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 12/19/16.
//
//

import Foundation
import CoreData

import ZaifSwift


public class BuyOrder: Order {
    
    override internal func createOrder(_ currencyPair: CurrencyPair, price: Double?, amount: Double) -> ZaifSwift.Order? {
        switch currencyPair {
        case .BTC_JPY:
            return Trade.Buy.Btc.In.Jpy.createOrder(price == nil ? nil : Int(price!), amount: amount)
        case .MONA_JPY:
            return Trade.Buy.Mona.In.Jpy.createOrder(price, amount: Int(amount))
        default:
            return nil
        }
    }
}
