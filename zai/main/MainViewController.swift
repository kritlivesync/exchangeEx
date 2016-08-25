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
        
        self.fundView = FundView(account: self.account)
        
        self.fundView.createMarketCapitalizationView() { err, data in
            self.marketCapitalization.text = data
            dispatch_async(dispatch_get_main_queue()) {
                self.marketCapitalization.setNeedsDisplay()
            }
        }
    }
    
    internal var account: Account!
    private var fundView: FundView!
    
    @IBOutlet weak var marketCapitalization: UILabel!
    
    @IBOutlet weak var traderTableView: UITableView!

}