//
//  BitCoin.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

@objc protocol BitCoinDelegate : MonitorableDelegate {
    @objc optional func recievedJpyPrice(price: Int)
}


internal class BitCoin : Monitorable {
    
    static func getPriceFor(_ currency: Currency, cb: @escaping (ZaiError?, Double) -> Void) {
        switch currency {
        case Currency.JPY:
            PublicApi.ticker(CurrencyPair.BTC_JPY) { (err, res) in
                if let e = err {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                } else {
                    if let r = res {
                        cb(nil, r["bid"].doubleValue)
                    } else {
                        cb(ZaiError(errorType: .ZAIF_API_ERROR), 0)
                    }
                }
            }
        default:
            cb(ZaiError(), 0)
        }
    }
    
    static func getBestAskQuote(_ currency: Currency, cb: @escaping (ZaiError?, Double, Double) -> Void) {
        switch currency {
        case Currency.JPY:
            PublicApi.depth(CurrencyPair.BTC_JPY) { (err, res) in
                if let e = err {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0, 0)
                } else {
                    if let r = res {
                        let quote = r["asks"].arrayValue[0].arrayValue
                        cb(nil, quote[0].doubleValue, quote[1].doubleValue)
                    } else {
                        cb(ZaiError(errorType: .ZAIF_API_ERROR), 0, 0)
                    }
                }
            }
        default:
            cb(ZaiError(), 0, 0)
        }
    }
    
    static func getBestBidQuote(_ currency: Currency, cb: @escaping (ZaiError?, Double, Double) -> Void) {
        switch currency {
        case Currency.JPY:
            PublicApi.depth(CurrencyPair.BTC_JPY) { (err, res) in
                if let e = err {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0, 0)
                } else {
                    if let r = res {
                        let quote = r["bids"].arrayValue[0].arrayValue
                        cb(nil, quote[0].doubleValue, quote[1].doubleValue)
                    } else {
                        cb(ZaiError(errorType: .ZAIF_API_ERROR), 0, 0)
                    }
                }
            }
        default:
            cb(ZaiError(), 0, 0)
        }
    }
    
    override func monitor() {
        let delegate = self.delegate as? BitCoinDelegate
        if delegate?.recievedJpyPrice != nil {
            BitCoin.getPriceFor(.JPY) { (err, price) in
                if err == nil {
                    delegate?.recievedJpyPrice?(price: Int(price))
                }
            }
        }
    }

}
