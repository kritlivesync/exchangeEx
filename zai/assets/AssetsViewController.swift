//
//  AssetsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 12/13/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

class AssetsViewController: UIViewController, FundDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.marketCapitalizationLabel.text = "-"
        self.jpyFundLabel.text = "-"
        self.btcFundLabel.text = "-"
        
        let account = getAccount()
        self.fund = Fund(api: account!.activeExchange.api)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fund.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fund.delegate = nil
    }

    // FundDelegate
    func recievedMarketCapitalization(jpy: Int) {
        DispatchQueue.main.async {
            self.marketCapitalizationLabel.text = formatValue(jpy)
        }
    }
    
    func recievedJpyFund(jpy: Int) {
        DispatchQueue.main.async {
            self.jpyFundLabel.text = formatValue(jpy)
        }
    }
    
    func recievedBtcFund(btc: Double) {
        DispatchQueue.main.async {
            self.btcFundLabel.text = formatValue(btc)
        }
    }
    
    var account: Account?
    var fund: Fund!
    
    @IBOutlet weak var marketCapitalizationLabel: UILabel!
    @IBOutlet weak var jpyFundLabel: UILabel!
    @IBOutlet weak var btcFundLabel: UILabel!
}
