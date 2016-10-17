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
    func didUpdateSignals(_ momentum: Double, isBullMarket: Bool)
    func didUpdateCount(_ count: Int)
    func didUpdateInterval(_ interval: Int)
}

class Analyzer : ZaifWatchDelegate {
    
    init(api: PrivateApi) {
        self.api = api
        self.marketPrice = MarketPrice(btcJpy: 0.0, monaJpy: 0.0, xemJpy: 0.0)
        self.macd = Macd(shortTerm: 3, longTerm: 6, signalTerm: 4)
        self.watch = ZaifWatch()
        self.watch.lastPriceWatchInterval = Double(self.lastPriceWatchInterval * 60)
        
        self.count = Int(self.watch.lastPriceWatchInterval)
        self.countDownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(Analyzer.countDown),
            userInfo: nil,
            repeats: true)
        
        self.watch.delegate = self
        
        let fund = JPYFund(api: self.api)
        fund.getMarketCapitalization() { (err, jpy) in
            if err == nil {
                self.prevJpFund = jpy
            }
        }
        self.updateWatchIntervalTimer = Timer.scheduledTimer(
            timeInterval: 3600.0,
            target: self,
            selector: #selector(Analyzer.updateWatchInterval),
            userInfo: nil,
            repeats: true)
    }
    
    func didFetchBtcJpyMarketPrice(_ price: Double) {
        self.marketPrice = MarketPrice(btcJpy: price, monaJpy: self.marketPrice.monaJpy, xemJpy: self.marketPrice.xemJpy)
    }
    
    func didFetchMonaJpyMarketPrice(_ price: Double) {
        self.marketPrice = MarketPrice(btcJpy: self.marketPrice.btcJpy, monaJpy: price, xemJpy: self.marketPrice.xemJpy)
    }
    
    func didFetchXemJpyMarketPrice(_ price: Double) {
        self.marketPrice = MarketPrice(btcJpy: self.marketPrice.btcJpy, monaJpy: self.marketPrice.monaJpy, xemJpy: price)
    }
    
    func didFetchBtcJpyLastPrice(_ price: Double) {
        self.count = Int(self.watch.lastPriceWatchInterval)
        
        self.macd.addSampleValue(price)

        if self.macd.valid {
            let average = self.macd.average(3)
            let prevAverage = self.average
            let momentum = (average - prevAverage) / self.watch.lastPriceWatchInterval
            let prevMomentum = self.momentum
            let isBullMomentum = (0 < momentum)
            let prevMomentumisBull = (0 < prevMomentum)
            var isBearMomuntum = false
            if self.momentumAtBuy > 0 {
                isBearMomuntum = (momentum < (self.momentumAtBuy * self.bearFactor))
            } else {
                isBearMomuntum = (momentum < (self.momentumAtBuy / (1 - self.bearFactor)))
            }
            
            if self.isTestBuy {
                if self.marketPrice.btcJpy < self.btcJpyPrice {
                    DispatchQueue.main.async {
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
                DispatchQueue.main.async {
                    if !self.isPreferBull {
                        self.delegate!.signaledBuy()
                        //self.momentumAtBuy = momentum
                        //self.isTestBuy = true
                        self.hasLongPos = true
                    } else {
                        self.delegate!.signaledSell()
                        self.momentumAtBuy = momentum
                        self.hasLongPos = false
                    }
                }
                print("sell")
            } else {
                if self.isBullMarket && isBearMomuntum {
                    self.isBullMarket = false
                    DispatchQueue.main.async {
                        if !self.isPreferBull {
                            self.delegate!.signaledSell()
                            self.hasLongPos = false
                        } else {
                            self.delegate!.signaledBuy()
                            //self.momentumAtBuy = momentum
                            //self.isTestBuy = true
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
    
    @objc func updateWatchInterval() {
        let fund = JPYFund(api: self.api)
        fund.getMarketCapitalization() { (err, jpy) in
            if err == nil {
                if jpy < self.prevJpFund {
                    self.isPreferBull = !self.isPreferBull
                    /*
                    var newInterval = self.lastPriceWatchInterval + 1
                    if newInterval > 5 {
                        newInterval = 3
                    }
                    self.watch.lastPriceWatchInterval = Double(newInterval * 60)
                    self.lastPriceWatchInterval = newInterval
                    
                    self.count = Int(self.watch.lastPriceWatchInterval)
                    */
                }
                self.prevJpFund = jpy
            }
        }
    }
    
    var marketPrice: MarketPrice
    var macd: Macd
    let watch: ZaifWatch!
    var lastPriceWatchInterval = 10
    var momentumAtBuy = 0.0
    var bearFactor = 0.3
    var isBullMarket = false
    var isPreferBull = true
    var isTestBuy = false
    var hasLongPos = false
    var momentum = 1.0
    var average = 0.0
    var btcJpyPrice = 0.0
    var delegate: AnalyzerDelegate? = nil
    
    var updateWatchIntervalTimer: Timer! = nil
    var prevJpFund: Int = 0
    
    
    var countDownTimer: Timer! = nil
    var count: Int
    
    var api: PrivateApi
}
