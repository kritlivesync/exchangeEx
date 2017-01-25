//
//  Api.swift
//  zai
//
//  Created by 渡部郷太 on 1/1/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON


public typealias ApiCallback = ((_ err: ApiError?, _ res: JSON?) -> Void)


public enum ApiCurrencyPair : String {
    case BTC_JPY = "btc_jpy"
}

public enum ApiCurrency : String {
    case BTC = "btc"
    case JPY = "jpy"
}


protocol Api {
    func getPrice(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Double) -> Void)
    func getTicker(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Tick) -> Void)
    func getBoard(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Board) -> Void)
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [String:Double]) -> Void)
    func getActiveOrders(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [String:ActiveOrder]) -> Void)
    func getTrades(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [Trade]) -> Void)
    
    func trade(order: Order, retryCount: Int, callback: @escaping (_ err: ApiError?, _ orderId: String, _ orderedPrice: Double) -> Void)
    func cancelOrder(order: ActiveOrder, retryCount: Int, callback: @escaping (_ err: ApiError?) -> Void)
    
    func validateApi(callback: @escaping (_ err: ApiError?) -> Void)
    
    func currencyPairs() -> [ApiCurrencyPair]
    func currencies() -> [ApiCurrency]
    func orderUnit(currencyPair: ApiCurrencyPair) -> Double
    
    var rawApi: Any { get }
}


protocol Stream {
    
}
