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
        
        self.stream = StreamingApi.stream(.BTC_JPY) { _,_ in
            print("opened btc_jpy streaming")
        }
        self.stream.onData(callback: self.onStreamData)
        
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
    
    func onStreamData(_ err: ZSError?, _ res: JSON?) {
        if let e = err {
            print(e.message)
            return
        }
        
        let board = Board()
        let asks = res!["asks"].arrayValue
        for ask in asks {
            let a = ask.arrayValue
            board.addAsk(price: a[0].doubleValue, amount: a[1].doubleValue)
        }
 
        let bids = res!["bids"].arrayValue
        for bid in bids {
            let b = bid.arrayValue
            board.addBid(price: b[0].doubleValue, amount: b[1].doubleValue)
        }
        if let d = self.delegate {
            d.didFetchBoard(board: board)
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
    let stream: ZaifSwift.Stream!
}
