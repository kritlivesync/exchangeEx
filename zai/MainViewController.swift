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
            if let _ = err {
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
        }
    }
    
    
    
    @IBOutlet weak var marketCapitalization: UILabel!
    
    internal var account: Account!
}