//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.account.getMarketCapitalization() { (err, value) in
            if err {
                self.marketCapitalization.text = "-"
            } else {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.groupingSeparator = ","
                formatter.groupingSize = 3
                formatter.maximumFractionDigits = 2
                self.marketCapitalization.text = formatter.stringFromNumber(value)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.marketCapitalization.setNeedsDisplay()
            }
            let order = ZaifSwift.Trade.Buy.Btc.In.Jpy.createOrder(50000, amount:1)

            self.account.trade(order) { (err, message) in
                if err {
                    print(message)
                }
            }
            
        }
    }
    
    
    
    @IBOutlet weak var marketCapitalization: UILabel!
    
    internal var account: Account!
}