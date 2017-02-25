//
//  bitFlyerApi.swift
//  zai
//
//  Created by 渡部郷太 on 2/14/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON
import bFSwift


fileprivate extension ApiCurrencyPair {
    
    var bFCurrencyPair: bFSwift.ProductCode {
        switch self {
        case .BTC_JPY:
            return bFSwift.ProductCode.btcJpy
        }
    }
}


fileprivate extension BFErrorCode {
    var apiError: ApiErrorType {
        switch self {
        //case ZSErrorType.INFO_API_NO_PERMISSION:
        //    return ApiErrorType.NO_PERMISSION
        //case ZSErrorType.TRADE_API_NO_PERMISSION:
        //    return ApiErrorType.NO_PERMISSION
        case BFErrorCode.connectionError:
            return ApiErrorType.CONNECTION_ERROR
        //case ZSErrorType.NONCE_NOT_INCREMENTED:
        //    return ApiErrorType.NONCE_NOT_INCREMENTED
        //case ZSErrorType.INVALID_API_KEY:
        //    return ApiErrorType.INVALID_API_KEY
        default:
            return ApiErrorType.UNKNOWN_ERROR
        }
    }
}


class bitFlyerApi : Api {
    
    init(apiKey: String, secretKey: String) {
        self.api = PrivateApi(apiKey: apiKey, secretKey: secretKey)
    }
    
    func getPrice(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Double) -> Void) {
        getTicker(currencyPair: currencyPair) { (err, tick) in
            callback(err, tick.lastPrice)
        }
    }
    
    func getTicker(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, Tick) -> Void) {
        PublicApi.getTicker(productCode: currencyPair.bFCurrencyPair) { (err, res) in
            if err != nil {
                print("getTicker: " + err!.message)
                callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), Tick())
            } else {
                guard let last = res?["ltp"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                /*
                guard let high = res?["high"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let low = res?["low"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let vwap = res?["vwap"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                */
                guard let volume = res?["volume"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let bid = res?["best_bid"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                guard let ask = res?["best_ask"].double else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), Tick())
                    return
                }
                let tick = Tick(lastPrice: last, highPrice: 0.0, lowPrice: 0.0, vwap: 0.0, volume: volume, bid: bid, ask: ask)
                callback(nil, tick)
            }
        }
    }
    
    func getBoard(currencyPair: ApiCurrencyPair, maxSize: Int, callback: @escaping (ApiError?, Board) -> Void) {
        PublicApi.getBoard(productCode: currencyPair.bFCurrencyPair) { (err, res) in
            let board = Board()
            if err != nil {
                print("getBoard: " + err!.message)
                callback(ApiError(errorType: err!.errorCode.apiError, message: err!.message), board)
            } else {
                guard let asks = res?["asks"].array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), board)
                    return
                }
                guard let bids = res?["bids"].array else {
                    callback(ApiError(errorType: .UNKNOWN_ERROR), board)
                    return
                }
                
                for ask in asks {
                    if let quote = ask.dictionary {
                        board.addAsk(price: quote["price"]!.doubleValue, amount: quote["size"]!.doubleValue)
                    }
                }
                
                for bid in bids {
                    if let quote = bid.dictionary {
                        board.addBid(price: quote["price"]!.doubleValue, amount: quote["size"]!.doubleValue)
                    }
                }
                
                board.sort()
                board.trunc(size: maxSize)
                
                callback(nil, board)
            }
        }
    }
    
    func getBalance(currencies: [ApiCurrency], callback: @escaping (ApiError?, [String:Double]) -> Void) {
        callback(ApiError(), [String:Double]())
    }
    
    func getActiveOrders(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [String:ActiveOrder]) -> Void) {
        callback(ApiError(), [String:ActiveOrder]())
    }
    
    func getTrades(currencyPair: ApiCurrencyPair, callback: @escaping (ApiError?, [Trade]) -> Void) {
        callback(ApiError(), [Trade]())
    }
    
    func trade(order: Order, retryCount: Int, callback: @escaping (_ err: ApiError?, _ orderId: String, _ orderedPrice: Double, _ orderedAmount: Double) -> Void) {
        callback(ApiError(), "", 0.0, 0.0)
    }
    
    func cancelOrder(order: ActiveOrder, retryCount: Int, callback: @escaping (_ err: ApiError?) -> Void) {
        callback(ApiError())
    }
    
    func createBoardStream(currencyPair: ApiCurrencyPair, maxSize: Int, onOpen: @escaping (ApiError?) -> Void, onClose: @escaping (ApiError?) -> Void, onError: @escaping (ApiError?) -> Void, onData: @escaping (ApiError?, Board) -> Void) -> StreamApi {
        
        return BitFlyerStreamApi()
    }
    
    func validateApi(callback: @escaping (_ err: ApiError?) -> Void) {
        bitFlyerApi.queue.async {
            let permissions = [
                PermissionType.getpermissions,
                PermissionType.getbalance,
                PermissionType.sendchildorder,
                PermissionType.cancelchildorder,
                PermissionType.cancelallchildorders,
                PermissionType.getchildorders,
                PermissionType.getexecutions,
            ]
            self.api.hasPermissions(permissions: permissions) { err, noPermissions in
                if noPermissions.count > 0 {
                    callback(ApiError(errorType: .NO_PERMISSION))
                } else {
                    callback(nil)
                }
                
            }
        }
    }
    
    func currencyPairs() -> [ApiCurrencyPair] {
        return [ApiCurrencyPair.BTC_JPY]
    }
    
    func currencies() -> [ApiCurrency] {
        return [ApiCurrency.JPY, ApiCurrency.BTC]
    }
    
    func orderUnit(currencyPair: ApiCurrencyPair) -> Double {
        return 0.00000001
    }
    
    var rawApi: Any {
        return self.api
    }
    
    static let queue = DispatchQueue(label: "bitflyerapiqueue")
    let api: bFSwift.PrivateApi
}


class BitFlyerStreamApi : StreamApi {
    func open() {
        
    }
    
    func close() {
        
    }
    
    var rawStream: Any {
        return 1
    }
}
