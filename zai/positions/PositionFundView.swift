//
//  PositionFundView.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

protocol PositionFundViewDelegate : MonitorableDelegate {
    func recievedTotalProfit(profit: String)
    func recievedPriceAverage(average: String)
    func recievedBtcFund(btc: String)
}

class PositionFundView : Monitorable {
    init(trader: Trader) {
        self.trader = trader
        super.init(target: "Position")
    }
    
    override func monitor() {
        let delegate = self.delegate as? PositionFundViewDelegate
        if self.delegate != nil {
            delegate?.recievedTotalProfit(profit: formatValue(Int(self.trader.totalProfit)))
            delegate?.recievedPriceAverage(average: formatValue(Int(round(self.trader.priceAverage))))
            let fund = Fund(api: self.trader.exchange.api)
            fund.getBtcFund() { (err, btc) in
                if err == nil {
                    DispatchQueue.main.async {
                        delegate?.recievedBtcFund(btc: formatValue(btc))
                    }
                }
            }
        }
    }
    
    let trader: Trader

}
