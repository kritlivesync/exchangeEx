//
//  Analyzer.swift
//  zai
//
//  Created by 渡部郷太 on 9/18/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


class MarketPrice {
    init(btcJpy: Double, monaJpy: Double, xemJpy: Double) {
        self.btcJpy = btcJpy
        self.monaJpy = monaJpy
        self.xemJpy = xemJpy
    }
    let btcJpy: Double
    let monaJpy: Double
    let xemJpy: Double
}


protocol AnalyzerDelegate {
    func signaledBuy()
    func signaledSell()
    func didUpdateSignals(momentum: Double, isBullMarket: Bool)
    func didUpdateCount(count: Int)
}

class Analyzer : ZaifWatchDelegate {
    
    init() {
        self.marketPrice = MarketPrice(btcJpy: 0.0, monaJpy: 0.0, xemJpy: 0.0)
        self.macd = Macd(shortTerm: 3, longTerm: 6, signalTerm: 4)
        self.watch = ZaifWatch()
        
        self.count = Int(self.watch.WATCH_LASTPRICE_INTERVAL)
        self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: #selector(Analyzer.countDown),
            userInfo: nil,
            repeats: true)
        
        self.watch.delegate = self
    }
    
    func didFetchBtcJpyMarketPrice(price: Double) {
        self.marketPrice = MarketPrice(btcJpy: price, monaJpy: self.marketPrice.monaJpy, xemJpy: self.marketPrice.xemJpy)
    }
    
    func didFetchMonaJpyMarketPrice(price: Double) {
        self.marketPrice = MarketPrice(btcJpy: self.marketPrice.btcJpy, monaJpy: price, xemJpy: self.marketPrice.xemJpy)
    }
    
    func didFetchXemJpyMarketPrice(price: Double) {
        self.marketPrice = MarketPrice(btcJpy: self.marketPrice.btcJpy, monaJpy: self.marketPrice.monaJpy, xemJpy: price)
    }
    
    func didFetchBtcJpyLastPrice(price: Double) {
        self.count = Int(self.watch.WATCH_LASTPRICE_INTERVAL)
        
        self.macd.addSampleValue(price)

        if self.macd.valid {
            let average = self.macd.average(3)
            let prevAverage = self.average
            let momentum = (average - prevAverage) / self.watch.WATCH_LASTPRICE_INTERVAL
            let prevMomentum = self.momentum
            let isBullMomentum = (0 < momentum)
            let prevMomentumisBull = (0 < prevMomentum)
            
            if self.isTestBuy {
                if self.marketPrice.btcJpy < self.btcJpyPrice {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate!.signaledSell()
                        self.hasLongPos = false
                    }
                    if self.isPreferBull && isBullMomentum {
                        self.isPreferBull = false
                    } else if !self.isPreferBull && !isBullMomentum{
                        self.isPreferBull = true
                    }
                }
                self.isTestBuy = false
            } else if !prevMomentumisBull && isBullMomentum && self.delegate != nil {
                self.isBullMarket = true
                dispatch_async(dispatch_get_main_queue()) {
                    if self.isPreferBull {
                        self.delegate!.signaledBuy()
                        self.isTestBuy = true
                        self.hasLongPos = true
                    } else {
                        self.delegate!.signaledSell()
                        self.hasLongPos = false
                    }
                }
                print("sell")
            } else {
                if self.isBullMarket && prevMomentumisBull && !isBullMomentum {
                    self.isBullMarket = false
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isPreferBull {
                            self.delegate!.signaledSell()
                            self.hasLongPos = false
                        } else {
                            self.delegate!.signaledBuy()
                            self.isTestBuy = true
                            self.hasLongPos = true
                        }
                    }
                    print("buy")
                }
            }
            self.momentum = momentum
            self.average = average
            self.btcJpyPrice = self.marketPrice.btcJpy
            
            if let d = self.delegate {
                d.didUpdateSignals(self.momentum, isBullMarket: self.isPreferBull)
            }
        }
    }
    
    @objc func countDown() {
        self.count -= 1
        if let d = self.delegate {
            d.didUpdateCount(self.count)
        }
    }
    
    var marketPrice: MarketPrice
    var macd: Macd
    let watch: ZaifWatch!
    var isBullMarket = false
    var isPreferBull = true
    var isTestBuy = false
    var hasLongPos = false
    var momentum = 1.0
    var average = 0.0
    var btcJpyPrice = 0.0
    var delegate: AnalyzerDelegate? = nil
    
    var countDownTimer: NSTimer! = nil
    var count: Int
}