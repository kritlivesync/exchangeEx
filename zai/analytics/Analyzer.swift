//
//  Analyzer.swift
//  zai
//
//  Created by 渡部郷太 on 9/18/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


class MarketPrice {
    var btcJpy: Double = 0.0
    var monaJpy: Double = 0.0
    var xemJpy: Double = 0.0
}

class Analyzer : ZaifWatchDelegate {
    
    init() {
        self.marketPice = MarketPrice()
        self.watch = ZaifWatch()
    }
    
    func didFetchBtcJpyMarketPrice(price: Double) {
        self.marketPice.btcJpy = price
    }
    
    func didFetchMonaJpyMarketPrice(price: Double) {
        self.marketPice.monaJpy = price
    }
    
    func didFetchXemJpyMarketPrice(price: Double) {
        self.marketPice.xemJpy = price
    }
    
    var marketPice: MarketPrice
    let watch: ZaifWatch!
}