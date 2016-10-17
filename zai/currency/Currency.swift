//
//  Currency.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal class BitCoin {
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
}

internal class MonaCoin {
    static func getPriceFor(_ currency: Currency, cb: @escaping (ZaiError?, Double) -> Void) {
        switch currency {
        case Currency.JPY:
            PublicApi.ticker(CurrencyPair.MONA_JPY) { (err, res) in
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
}

internal class XEM {
    static func getPriceFor(_ currency: Currency, cb: @escaping (ZaiError?, Double) -> Void) {
        switch currency {
        case Currency.JPY:
            PublicApi.ticker(CurrencyPair.XEM_JPY) { (err, res) in
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
}
