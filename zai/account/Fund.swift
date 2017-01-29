//
//  Fund.swift
//  zai
//
//  Created by Kyota Watanabe on 8/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
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
        super.init(target: "Fund")
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
        if delegate?.recievedMarketCapitalization != nil || delegate?.recievedJpyFund != nil || delegate?.recievedBtcFund != nil {
            self.api.getBalance(currencies: [.BTC, .JPY]) { (err, balances) in
                if err == nil {
                    let jpy = balances[ApiCurrency.JPY.rawValue]!
                    let btc = balances[ApiCurrency.BTC.rawValue]!
                    DispatchQueue.main.async {
                        delegate?.recievedJpyFund?(jpy: Int(jpy))
                    }
                    DispatchQueue.main.async {
                        delegate?.recievedBtcFund?(btc: btc)
                    }
                    
                    let bitcoin = BitCoin(api: self.api)
                    bitcoin.getPriceFor(.JPY) { (err, price) in
                        if err == nil {
                            DispatchQueue.main.async {
                                let total = jpy + (btc * price)
                                delegate?.recievedMarketCapitalization?(jpy: Int(total))
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate let api: Api
}
