//
//  Watch.swift
//  zai
//
//  Created by 渡部郷太 on 9/17/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift
import SwiftyJSON


protocol ZaifWatchDelegate {
    func didFetchBtcJpyMarketPrice(_ price: Double)
    func didFetchMonaJpyMarketPrice(_ price: Double)
    func didFetchXemJpyMarketPrice(_ price: Double)
    func didFetchBtcJpyLastPrice(_ price: Double)
    func didFetchBoard(board: Board)
}


class ZaifWatch {
    
    init() {
        self.queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        
        self.marketPriceTimer = Timer.scheduledTimer(
            timeInterval: self.WATCH_MARKETPRICE_INTERVAL,
            target: self,
            selector: #selector(ZaifWatch.addMarketPriceOperation),
            userInfo: nil,
            repeats: true)
        
        self.addMarketPriceOperation()
    }
    
    @objc func addMarketPriceOperation() {
        self.queue.async {
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

    var lastPriceWatchInterval: Double {
        get {
            if let _ = self.lastPriceTimer {
                return Double(self.lastPriceTimer.timeInterval)
            } else {
                return 0.0
            }
        }
        set {
            if let timer = self.lastPriceTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            
            self.lastPriceTimer = Timer.scheduledTimer(
                   timeInterval: newValue,
                   target: self,
                   selector: #selector(ZaifWatch.addLastPriceOperation),
                   userInfo: nil,
                   repeats: true)
        }
    }
    
    let queue: DispatchQueue
    var marketPriceTimer: Timer!
    var lastPriceTimer: Timer!
    var delegate: ZaifWatchDelegate? = nil
    let WATCH_MARKETPRICE_INTERVAL = 5.0 // seconds
}
