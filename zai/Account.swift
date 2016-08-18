//
//  Account.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON

import ZaifSwift


internal class Account {
    init(api: PrivateApi) {
        self.privateApi = api
    }
    
    func getMarketCapitalization(callback: ((err: Bool, value: Double) -> Void)) {
        self.privateApi.getInfo() { (err, res) in
            if err != nil {
                callback(err: true, value: 0)
            } else {
                if let info = res {
                    var total = info["return"]["deposit"]["jpy"].doubleValue
                    let btc = info["return"]["deposit"]["btc"].doubleValue
                    let mona = info["return"]["deposit"]["mona"].doubleValue
                
                    let semaphore = dispatch_semaphore_create(1)
                    var tickCount = 2
                    
                    PublicApi.ticker(CurrencyPair.BTC_JPY) { (err, res) in
                        if err != nil {
                            callback(err: true, value: 0)
                        } else {
                            if let btc_jpy = res {
                                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                                total += (btc * btc_jpy["bid"].doubleValue)
                                tickCount -= 1
                                dispatch_semaphore_signal(semaphore)
                                if (tickCount == 0) {
                                    callback(err: false, value: total)
                                }
                            } else {
                                callback(err: true, value: 0)
                            }
                        }
                    }
                    PublicApi.ticker(CurrencyPair.MONA_JPY) { (err, res) in
                        if err != nil {
                            callback(err: true, value: 0)
                        } else {
                            if let mona_jpy = res {
                                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                                total += (mona * mona_jpy["bid"].doubleValue)
                                tickCount -= 1
                                dispatch_semaphore_signal(semaphore)
                                if (tickCount == 0) {
                                    callback(err: false, value: total)
                                }
                            } else {
                                callback(err: true, value: 0)
                            }
                        }
                    }
                } else {
                    callback(err: true, value: 0)
                }
            }
        }
    }
    
    func trade(order: Order, callback: ((err: Bool, message: String) -> Void)) {
        self.privateApi.trade(order) { (err, res) in
            if let e = err {
                callback(err: true, message: e.message)
            }
        }
    }
    
    private let privateApi: PrivateApi
}