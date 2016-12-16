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


class ZaifWatch: FundDelegate, BitCoinDelegate {
    
    init() {
        
    }
    
    
    
    // FundDelegate
    func recievedMarketCapitalization(jpy: Int) {
        
    }
    func recievedJpyFund(jpy: Int) {
        
    }
    func recievedBtcFund(btc: Double) {
        
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        
    }
    
    let fund: Fund! = nil
    let bitcoin: BitCoin! = nil
    var marketCapitalization = 0
    var jpyFund = 0
    var btcFund = 0.0
    var btcJpyPrice = 0
}
