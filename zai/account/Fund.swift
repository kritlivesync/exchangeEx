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
    @objc optional func recievedJpyFund(jpy: Int, available: Int)
    @objc optional func recievedBtcFund(btc: Double, available: Double)
}


internal class Fund : Monitorable {
    init(api: Api) {
        self.api = api
        super.init(target: "Fund")
    }
 
    func getMarketCapitalization(_ cb: @escaping ((ZaiError?, Int) -> Void)) {
        self.api.getBalance(currencies: [.JPY, .BTC]) { (err, balances) in
            if err != nil {
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), 0)
            } else {
                var total = balances[0].amount
                let btc = balances[1].amount
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
            
            let jpyFund = balance[0].available
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
                let jpyFund = balance[0].amount
                cb(nil, Int(jpyFund))
            }
        }
    }
    
    func getBtcFund(_ cb: @escaping ((ZaiError?, Balance) -> Void)) {
        self.api.getBalance(currencies: [.BTC]) { (err, balances) in
            if err != nil {
                let balance = Balance(currency: ApiCurrency.BTC, amount: 0.0, available: 0.0)
                cb(ZaiError(errorType: .ZAIF_API_ERROR, message: err!.message), balance)
                return
            } else {
                cb(nil, balances[0])
            }
        }
    }
    
    override func monitor() {
        let delegate = self.delegate as? FundDelegate
        if delegate?.recievedMarketCapitalization != nil || delegate?.recievedJpyFund != nil || delegate?.recievedBtcFund != nil {
            self.api.getBalance(currencies: [.JPY, .BTC]) { (err, balances) in
                if err == nil {
                    let jpy = balances[0]
                    let btc = balances[1]
                    DispatchQueue.main.async {
                        delegate?.recievedJpyFund?(jpy: Int(jpy.amount), available: Int(jpy.available))
                    }
                    DispatchQueue.main.async {
                        delegate?.recievedBtcFund?(btc: btc.amount, available: btc.available)
                    }
                    
                    let bitcoin = BitCoin(api: self.api)
                    bitcoin.getPriceFor(.JPY) { (err, price) in
                        if err == nil {
                            DispatchQueue.main.async {
                                let total = jpy.amount + (btc.amount * price)
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
