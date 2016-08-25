//
//  Fund.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON

import ZaifSwift


internal class JPYFund {
    init(api: PrivateApi) {
        self.privateApi = api
    }
 
    func getMarketCapitalization(cb: ((ZaiError?, Int) -> Void)) {
        self.privateApi.getInfo() { (err, res) in
            if let e = err {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
            } else {
                if let info = res {
                    var total = info["return"]["deposit"]["jpy"].doubleValue
                    let btc = info["return"]["deposit"]["btc"].doubleValue
                    let mona = info["return"]["deposit"]["mona"].doubleValue
                    let xem = info["return"]["deposit"]["xem"].doubleValue
                    BitCoin.getPriceFor(.JPY) { (err, btcPrice) in
                        if let e = err {
                            cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                        } else {
                            total += (btc * Double(btcPrice))
                            MonaCoin.getPriceFor(.JPY) { (err, monaPrice) in
                                if let e = err {
                                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                                } else {
                                    total += (mona * monaPrice)
                                    XEM.getPriceFor(.JPY) { (err, xemPrice) in
                                        if let e = err {
                                            cb(ZaiError(errorType: .ZAIF_API_ERROR, message: e.message), 0)
                                        } else {
                                            total += (xem * xemPrice)
                                            cb(nil, Int(total))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    private let privateApi: PrivateApi
}