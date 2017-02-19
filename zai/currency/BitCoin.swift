//
//  BitCoin.swift
//  zai
//
//  Created by Kyota Watanabe on 12/11/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation


@objc protocol BitCoinDelegate : MonitorableDelegate {
    @objc optional func recievedJpyPrice(price: Int)
    @objc optional func recievedBestJpyBid(price: Int, amount: Double)
    @objc optional func recievedBestJpyAsk(price: Int, amount: Double)
}


internal class BitCoin : Monitorable {
    
    init(api: Api) {
        self.api = api
        super.init(target: "BitCoin")
    }
    
    func getPriceFor(_ currency: ApiCurrency, cb: @escaping (ZaiError?, Double) -> Void) {
        switch currency {
        case ApiCurrency.JPY:
            self.api.getPrice(currencyPair: ApiCurrencyPair.BTC_JPY) { (err, price) in
                if err != nil {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0.0)
                } else {
                    cb(nil, price)
                }
            }
        default:
            cb(ZaiError(), 0)
        }
    }
    
    func getBestAskQuote(_ currency: ApiCurrency, cb: @escaping (ZaiError?, Quote?) -> Void) {
        switch currency {
        case ApiCurrency.JPY:
            self.api.getBoard(currencyPair: ApiCurrencyPair.BTC_JPY, maxSize: 1) { (err, board) in
                if err != nil {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), nil)
                } else {
                    guard let quote = board.getBestAsk() else {
                        cb(ZaiError(errorType: .ZAIF_API_ERROR), nil)
                        return
                    }
                    cb(nil, quote)
                }
            }
        default:
            cb(ZaiError(), nil)
        }
    }
    
    func getBestBidQuote(_ currency: ApiCurrency, cb: @escaping (ZaiError?, Quote?) -> Void) {
        switch currency {
        case ApiCurrency.JPY:
            self.api.getBoard(currencyPair: ApiCurrencyPair.BTC_JPY, maxSize: 1) { (err, board) in
                if err != nil {
                    cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), nil)
                } else {
                    guard let quote = board.getBestBid() else {
                        cb(ZaiError(errorType: .ZAIF_API_ERROR), nil)
                        return
                    }
                    cb(nil, quote)
                }
            }
        default:
            cb(ZaiError(), nil)
        }
    }
    
    override func monitor() {
        let delegate = self.delegate as? BitCoinDelegate
        if delegate?.recievedJpyPrice != nil {
            self.getPriceFor(.JPY) { (err, price) in
                if err == nil {
                    DispatchQueue.main.async {
                        delegate?.recievedJpyPrice?(price: Int(price))
                    }
                }
            }
        }
        if delegate?.recievedBestJpyBid != nil || delegate?.recievedBestJpyAsk != nil {
            self.api.getBoard(currencyPair: ApiCurrencyPair.BTC_JPY, maxSize: 1) { (err, board) in
                if err == nil {
                    if let bestBid = board.getBestBid() {
                        DispatchQueue.main.async {
                            delegate?.recievedBestJpyBid?(price: Int(bestBid.price), amount: bestBid.amount)
                        }
                    }
                    if let bestAsk = board.getBestAsk() {
                        DispatchQueue.main.async {
                            delegate?.recievedBestJpyAsk?(price: Int(bestAsk.price), amount: bestAsk.amount)
                        }
                    }
                }
            }
        }
    }

    let api: Api
    static let Satoshi = 0.00000001
}
