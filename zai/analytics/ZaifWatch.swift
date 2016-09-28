//
//  Watch.swift
//  zai
//
//  Created by 渡部郷太 on 9/17/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


protocol ZaifWatchDelegate {
    func didFetchBtcJpyMarketPrice(price: Double)
    func didFetchMonaJpyMarketPrice(price: Double)
    func didFetchXemJpyMarketPrice(price: Double)
    func didFetchBtcJpyLastPrice(price: Double)
}


class ZaifWatch {
    
    init() {
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        self.marketPriceTimer = NSTimer.scheduledTimerWithTimeInterval(
            self.WATCH_MARKETPRICE_INTERVAL,
            target: self,
            selector: #selector(ZaifWatch.addMarketPriceOperation),
            userInfo: nil,
            repeats: true)
        
        self.marketPriceTimer = NSTimer.scheduledTimerWithTimeInterval(
            self.WATCH_LASTPRICE_INTERVAL,
            target: self,
            selector: #selector(ZaifWatch.addLastPriceOperation),
            userInfo: nil,
            repeats: true)
        
        self.addMarketPriceOperation()
    }
    
    @objc func addMarketPriceOperation() {
        dispatch_async(self.queue) {
            BitCoin.getPriceFor(.JPY) { (err, price) in
                if err == nil && self.delegate != nil {
                    self.delegate!.didFetchBtcJpyMarketPrice(price)
                }
            }
            MonaCoin.getPriceFor(.JPY) { (err, price) in
                if err == nil && self.delegate != nil {
                    self.delegate!.didFetchMonaJpyMarketPrice(price)
                }
            }
            XEM.getPriceFor(.JPY) { (err, price) in
                if err == nil && self.delegate != nil {
                    self.delegate!.didFetchXemJpyMarketPrice(price)
                }
            }
        }
    }
    
    @objc func addLastPriceOperation() {
        PublicApi.lastPrice(.BTC_JPY) { (err, res) in
            if err == nil && self.delegate != nil {
                let price = res!["last_price"].doubleValue
                self.delegate!.didFetchBtcJpyLastPrice(price)
            }
        }
    }

    
    let queue: dispatch_queue_t
    var marketPriceTimer: NSTimer!
    var lastPriceTimer: NSTimer!
    var delegate: ZaifWatchDelegate? = nil
    let WATCH_MARKETPRICE_INTERVAL = 10.0 // seconds
    let WATCH_LASTPRICE_INTERVAL = 180.0
}