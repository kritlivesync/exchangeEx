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
    
    @IBAction func pushCreateButton(_ sender: AnyObject) {
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
        
        repository.create(traderName, account: self.account)
        
        self.performSegue(withIdentifier: self.backToSelectTraderSeque, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case self.backToSelectTraderSeque:
            let destController = segue.destination as! SelectTraderViewController
            destController.account = self.account!
        default: break
        }
    }

    @IBOutlet weak var traderNameText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    fileprivate let backToSelectTraderSeque = "backToSelectTraderSeque"
    
    internal var account: Account!
}
