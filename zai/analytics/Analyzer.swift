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
    func recievedBoard(board: Board)
}

class Analyzer : ZaifWatchDelegate, ZaiAnalyticsDelegate {
    
    init(api: PrivateApi) {
        self.api = api
        self.marketPrice = MarketPrice(btcJpy: 0.0, monaJpy: 0.0, xemJpy: 0.0)
        self.macd = Macd(shortTerm: self.feature.shortTerm, longTerm: self.feature.longTerm, signalTerm: self.feature.signalTerm)
        
        self.lastPriceDate = Int(Date().timeIntervalSince1970) - self.feature.priceInterval
        
        //self.analyticsClient = ZaiAnalyticsClient()
        
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
    }
    
    func didFetchBoard(board: Board) {
        if let d = self.delegate {
            d.recievedBoard(board: board)
        }
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
