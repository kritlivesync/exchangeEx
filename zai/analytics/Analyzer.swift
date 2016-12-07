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
}

class Analyzer : ZaifWatchDelegate, ZaiAnalyticsDelegate {
    
    init(api: PrivateApi) {
        self.api = api
        self.marketPrice = MarketPrice(btcJpy: 0.0, monaJpy: 0.0, xemJpy: 0.0)
        self.macd = Macd(shortTerm: self.feature.shortTerm, longTerm: self.feature.longTerm, signalTerm: self.feature.signalTerm)
        self.watch = ZaifWatch()
        self.watch.lastPriceWatchInterval = Double(self.lastPriceWatchInterval)
        
        self.lastPriceDate = Int(Date().timeIntervalSince1970) - self.feature.priceInterval
        
        //self.analyticsClient = ZaiAnalyticsClient()
        
        self.watch.delegate = self
        //self.analyticsClient.delegate = self
    }
    
    
    // ZaifWatchDelegate
    
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
        return
        
        let now = Int(Date().timeIntervalSince1970)
        if (now - self.lastPriceDate) < self.feature.priceInterval {
            return
        }
        self.lastPriceDate = now
        
        self.macd.addSampleValue(price)
        if !self.macd.valid {
            return
        }
        
        let average = self.macd.average(self.feature.averageTerm)
        let prevAverage = self.average
        let momentum = (average - prevAverage)

        if self.momentumHistory.count >= 2 {
            let historySlice = Array(self.momentumHistory.suffix(2))
            if historySlice[1] < historySlice[0] && historySlice[1] < momentum {
                self.currentBottomMomentum = historySlice[1]
            }
            
            var isMomentumBull = false
            if self.currentBottomMomentum >= 0 {
                isMomentumBull = ((self.currentBottomMomentum * self.feature.bullFactor) <= momentum)
            } else {
                let dif = momentum - self.currentBottomMomentum
                let absPrev = abs(self.currentBottomMomentum)
                isMomentumBull = ((absPrev * self.feature.bullFactor) <= (absPrev + dif))
            }
            
            var isMomuntumBear = false
            if self.momentumAtBuy >= 0 {
                isMomuntumBear = (momentum < (self.momentumAtBuy * self.feature.bearFactor))
            } else {
                isMomuntumBear = (momentum < (self.momentumAtBuy / (1 - self.feature.bearFactor)))
            }
            
            if isMomentumBull && self.delegate != nil {
                self.isBullMarket = true
                DispatchQueue.main.async {
                    self.delegate!.signaledBuy()
                    self.momentumAtBuy = momentum
                    self.currentBottomMomentum = 9999999.9
                }
                print("buy")
            } else {
                if self.isBullMarket && isMomuntumBear {
                    self.isBullMarket = false
                    DispatchQueue.main.async {
                        self.delegate!.signaledSell()
                    }
                    print("sell")
                }
            }
        }
        
        self.momentumHistory.append(momentum)
        if self.HISTORY_SIZE < self.momentumHistory.count {
            self.momentumHistory.remove(at: 0)
        }
        self.average = average
        self.btcJpyPrice = self.marketPrice.btcJpy
    }
    
    // ZaiAnalyticsDelegate
    func recievedBuySignal() {
        DispatchQueue.main.async {
            self.delegate!.signaledBuy()
            //self.delegate!.signaledSell()
        }
        print("buy: " + getNow())
    }
    
    func recievedSellSignal() {
        DispatchQueue.main.async {
            self.delegate!.signaledSell()
            //self.delegate!.signaledBuy()
        }
        print("sell: " + getNow())
    }
    
    var marketPrice: MarketPrice
    var macd: Macd
    let watch: ZaifWatch!
    var lastPriceWatchInterval = 10
    var momentumAtBuy = 0.0
    var currentBottomMomentum = 9999999.9
    let feature = Feature()
    var isBullMarket = false

    var momentumHistory = [Double]()
    let HISTORY_SIZE = 20
    var average = 0.0
    var btcJpyPrice = 0.0
    var delegate: AnalyzerDelegate? = nil
    
    var lastPriceDate = 0
    
    //let analyticsClient: ZaiAnalyticsClient!
    
    var api: PrivateApi
}
