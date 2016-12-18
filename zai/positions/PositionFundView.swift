//
//  PositionFundView.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

protocol PositionFundViewDelegate {
    func recievedTotalProfit(profit: String)
    func recievedPriceAverage(average: String)
    func recievedBtcFund(btc: String)
}

class PositionFundView : Monitorable {
    init(trader: Trader) {
        self.trader = trader
        super.init()
    }
    
    override func monitor() {
        if self.delegate != nil {
            self.delegate?.recievedTotalProfit(profit: formatValue(Int(self.trader.totalProfit)))
            self.delegate?.recievedPriceAverage(average: formatValue(Int(round(self.trader.priceAverage))))
            let fund = Fund(api: self.trader.account.privateApi)
            fund.getBtcFund() { (err, btc) in
                if err == nil {
                    self.delegate?.recievedBtcFund(btc: formatValue(btc))
                }
            }
        }
    }
    
    let trader: Trader
    var delegate: PositionFundViewDelegate?
}
