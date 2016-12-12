//
//  Fund.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON

import ZaifSwift


protocol FundDelegate {
    func recievedMarketCapitalization(jpy: Int)
    func recievedJpyFund(jpy: Int)
    func recievedBtcFund(btc: Double)
}

internal class Fund : Monitorable {
    init(api: PrivateApi) {
        self.privateApi = api
    }
 
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        self.privateApi.getInfo() { (err, res) in
            if let e = err {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
            } else {
                if let info = res {
                    var total = info["return"]["deposit"]["jpy"].doubleValue
                    let btc = info["return"]["deposit"]["btc"].doubleValue
                    let mona = info["return"]["deposit"]["mona"].doubleValue
                    let xem = info["return"]["deposit"]["xem"].doubleValue
                    BitCoin.getPriceFor(.JPY) { (err, btcPrice) in
                        if let e = err {
                            cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                        } else {
                            total += (btc * Double(btcPrice))
                            MonaCoin.getPriceFor(.JPY) { (err, monaPrice) in
                                if let e = err {
                                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                                } else {
                                    total += (mona * monaPrice)
                                    XEM.getPriceFor(.JPY) { (err, xemPrice) in
                                        if let e = err {
                                            cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                                        } else {
                                            total += (xem * xemPrice)
                                            cb(nil, Int(total))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calculateHowManyAmountCanBuy(_ currency: Currency, price: Double? = nil, rate: Double = 1.0, cb: @escaping (ZaiError?, Double, Double) -> Void) {
        self.privateApi.getInfo() { (err, res) in
            if let e = err {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0, 0)
            } else {
                if let info = res {
                    let jpyFund = info["return"]["deposit"]["jpy"].doubleValue
                    var currencyPair = CurrencyPair.BTC_JPY
                    switch currency {
                    case .MONA:
                        currencyPair = .MONA_JPY
                    case .XEM:
                        currencyPair = .XEM_JPY
                    default: break
                    }
                    if let p = price {
                        let amount = jpyFund * rate / p
                        cb(nil, amount, p)
                    } else {
                        PublicApi.lastPrice(currencyPair) { (err, res) in
                            if let e = err {
                                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0, 0)
                            } else {
                                let price = res!["last_price"].doubleValue
                                var amount = jpyFund * rate / price
                                switch currency {
                                case .BTC:
                                    amount = Double(Int(amount * 10000)) / 10000.0
                                case .MONA:
                                    amount = Double(Int(amount))
                                default: break
                                }
                                cb(nil, amount, price)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getJpyFund(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        self.privateApi.getInfo() { (err, res) in
            if let e = err {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
            } else {
                if let info = res {
                    let jpy = info["return"]["deposit"]["jpy"].intValue
                    cb(nil, jpy)
                }
            }
        }
    }
    
    func getBtcFund(_ cb: @escaping ((ZaiError?, Double) -> Void)) {
        self.privateApi.getInfo() { (err, res) in
            if let e = err {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
            } else {
                if let info = res {
                    let btc = info["return"]["deposit"]["btc"].doubleValue
                    cb(nil, btc)
                }
            }
        }
    }
    
    override func monitor() {
        if let d = delegate {
            self.getMarketCapitalization() { (err, jpy) in
                if err == nil {
                    d.recievedMarketCapitalization(jpy: jpy)
                }
            }
            self.getJpyFund() { (err, jpy) in
                if err == nil && self.delegate != nil {
                    d.recievedJpyFund(jpy: jpy)
                }
            }
            self.getBtcFund() { (err, btc) in
                if err == nil && self.delegate != nil {
                    d.recievedBtcFund(btc: btc)
                }
            }
        }
    }
    
    fileprivate let privateApi: PrivateApi
    var delegate: FundDelegate? = nil
}
