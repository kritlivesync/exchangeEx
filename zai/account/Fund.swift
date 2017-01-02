//
//  Fund.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


@objc protocol FundDelegate : MonitorableDelegate {
    @objc optional func recievedMarketCapitalization(jpy: Int)
    @objc optional func recievedJpyFund(jpy: Int)
    @objc optional func recievedBtcFund(btc: Double)
}


internal class Fund : Monitorable {
    init(api: Api) {
        self.api = api
    }
 
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        self.api.getBalance(currencies: [.BTC, .JPY]) { (err, balances) in
            if err != nil {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0)
            } else {
                var total = balances[ApiCurrency.JPY.rawValue]!
                let btc = balances[ApiCurrency.BTC.rawValue]!
                let bitcoin = BitCoin(api: self.api)
                bitcoin.getPriceFor(.JPY) { (err, price) in
                    if err != nil {
                        cb(err, 0)
                    } else {
                        total += (btc * price)
                        cb(nil, Int(total))
                    }
                }
            }
        }
    }
    
    func calculateHowManyAmountCanBuy(_ currency: ApiCurrency, price: Double? = nil, rate: Double = 1.0, cb: @escaping (ZaiError?, Double, Double) -> Void) {
        
        self.api.getBalance(currencies: [.JPY]) { (err, balance) in
            if err != nil {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0.0, 0.0)
                return
            }
            
            let jpyFund = balance[ApiCurrency.JPY.rawValue]!
            if let p = price {
                let amount = jpyFund * rate / p
                cb(nil, amount, p)
                return
            }
            switch currency {
            case .BTC:
                let bitcoin = BitCoin(api: self.api)
                bitcoin.getPriceFor(.JPY) { (err, price) in
                    let amount = jpyFund * rate / price
                    cb(err, amount, price)
                }
            default:
                cb(ZaiError(), 0.0, 0.0)
            }
        }
    }
    
    func getJpyFund(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        self.api.getBalance(currencies: [.JPY]) { (err, balance) in
            if err != nil {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0)
                return
            } else {
                let jpyFund = balance[ApiCurrency.JPY.rawValue]!
                cb(nil, Int(jpyFund))
            }
        }
    }
    
    func getBtcFund(_ cb: @escaping ((ZaiError?, Double) -> Void)) {
        self.api.getBalance(currencies: [.BTC]) { (err, balance) in
            if err != nil {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0.0)
                return
            } else {
                let btcFund = balance[ApiCurrency.BTC.rawValue]!
                cb(nil, btcFund)
            }
        }
    }
    
    override func monitor() {
        let delegate = self.delegate as? FundDelegate
        if delegate?.recievedMarketCapitalization != nil {
            self.getMarketCapitalization() { (err, jpy) in
                if err == nil {
                    delegate?.recievedMarketCapitalization?(jpy: jpy)
                }
            }
        }
        if delegate?.recievedJpyFund != nil {
            self.getJpyFund() { (err, jpy) in
                if err == nil {
                    delegate?.recievedJpyFund?(jpy: jpy)
                }
            }
        }
        if delegate?.recievedBtcFund != nil {
            self.getBtcFund() { (err, btc) in
                if err == nil {
                    delegate?.recievedBtcFund?(btc: btc)
                }
            }
        }
    }
    
    fileprivate let api: Api
}
