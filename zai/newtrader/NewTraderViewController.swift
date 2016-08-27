//
//  NewTraderViewController.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


class NewTraderViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func pushCreateButton(sender: AnyObject) {
        let traderName = self.traderNameText.text!
        if traderName == "" {
            self.errorMessageLabel.text = "Invalid trader name"
            return
        }
    
        let repository = TraderRepository.getInstance()
        let trader = repository.findTraderByName(traderName, api: self.account.privateApi)
        if let _ = trader {
            self.errorMessageLabel.text = "Trader name already exists"
            return
        }
        
        let newTrader = StrongTrader(name: traderName, account: self.account)
        repository.register(newTrader)
        
        self.performSegueWithIdentifier("backToSelectTraderSegue", sender: self)
    }

    @IBOutlet weak var traderNameText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    internal var account: Account!
}
