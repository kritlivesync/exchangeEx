//
//  FundView.swift
//  zai
//
//  Created by 渡部郷太 on 8/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


internal class FundView {
    
    init(account: Account) {
        self.account = account
    }
    
    func createMarketCapitalizationView(cb: (ZaiError?, String) -> Void) {
        self.account.getMarketCapitalization() { (err, value) in
            if let e = err {
                cb(e, "-")
            } else {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.groupingSeparator = ","
                formatter.groupingSize = 3
                formatter.maximumFractionDigits = 2
                cb(nil, formatter.stringFromNumber(value)!)
            }
        }
    }
    
    private let account: Account
}