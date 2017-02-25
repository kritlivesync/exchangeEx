//
//  Api.swift
//  zai
//
//  Created by Kyota Watanabe on 1/1/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
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
    func getBoard(currencyPair: ApiCurrencyPair, maxSize: Int, callback: @escaping (ApiError?, Board) -> Void)
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [String:Double]) -> Void)
    func getActiveOrders(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [String:ActiveOrder]) -> Void)
    func getTrades(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [Trade]) -> Void)
    
    func trade(order: Order, retryCount: Int, callback: @escaping (_ err: ApiError?, _ orderId: String, _ orderedPrice: Double, _ orderedAmount: Double) -> Void)
    func cancelOrder(order: ActiveOrder, retryCount: Int, callback: @escaping (_ err: ApiError?) -> Void)
    
    func createBoardStream(
        currencyPair: ApiCurrencyPair,
        maxSize: Int,
        onOpen: @escaping (ApiError?) -> Void,
        onClose: @escaping (ApiError?) -> Void,
        onError: @escaping (ApiError?) -> Void,
        onData: @escaping (ApiError?, Board) -> Void
    ) -> StreamApi
    
    func validateApi(callback: @escaping (_ err: ApiError?) -> Void)
    
    func currencyPairs() -> [ApiCurrencyPair]
    func currencies() -> [ApiCurrency]
    func orderUnit(currencyPair: ApiCurrencyPair) -> Double
    
    var rawApi: Any { get }
}


protocol StreamApi {
    func open()
    func close()
    
    var rawStream: Any { get }
}
