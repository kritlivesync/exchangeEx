//
//  Watch.swift
//  zai
//
//  Created by 渡部郷太 on 9/17/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


protocol ZaifWatchDelegate {
    func didFetchBtcJpyMarketPrice(price: Double)
    func didFetchMonaJpyMarketPrice(price: Double)
    func didFetchXemJpyMarketPrice(price: Double)
}


class ZaifWatch {
    
    init() {
        self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        self.marketPriceTimer = NSTimer.scheduledTimerWithTimeInterval(
            3,
            target: self,
            selector: #selector(ZaifWatch.addMarketPriceOperation),
            userInfo: nil,
            repeats: false)
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

    
    let queue: dispatch_queue_t
    var marketPriceTimer: NSTimer!
    var delegate: ZaifWatchDelegate? = nil
}