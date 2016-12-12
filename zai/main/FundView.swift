//
//  FundView.swift
//  zai
//
//  Created by 渡部郷太 on 8/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

protocol FundViewDelegate {
    func didUpdateMarketCapitalization(_ view: String)
    func didUpdateBtcJpyPrice(_ view: String)
    func didUpdateBtcFund(_ view: String)
}


internal class FundView : FundDelegate, BitCoinDelegate {
    
    init(account: Account) {
        self.account = account
        self.fund = Fund(api: account.privateApi)
        self.btc = BitCoin()
        self.fund.delegate = self
        self.btc.delegate = self
    }
    
    fileprivate func formatValue(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value))!
    }
    
    // FundDelegate
    func recievedMarketCapitalization(jpy: Int) {
        if let d = self.delegate {
            d.didUpdateMarketCapitalization(self.formatValue(jpy))
        }
    }
    
    func recievedBtcFund(btc: Double) {
        if let d = self.delegate {
            d.didUpdateBtcFund(NSString(format: "%.4f", btc) as String)
        }
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        if let d = self.delegate {
            d.didUpdateBtcJpyPrice(self.formatValue(price))
        }
    }
    
    fileprivate let account: Account
    fileprivate let fund: Fund
    fileprivate let btc: BitCoin
    var delegate: FundViewDelegate? = nil
}
