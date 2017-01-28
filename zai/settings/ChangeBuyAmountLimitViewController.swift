//
//  ChangeBuyAmountLimitViewController.swift
//  zai
//
//  Created by 渡部郷太 on 1/22/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ChangeBuyAmountLimitDelegate {
    func saved(amount: Double)
}


class ChangeBuyAmountLimitViewController : UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.config = getAppConfig()
        self.maxBuyAmountLabel.text = self.config.buyAmountLimitBtc.description
        self.maxBuyAmountLabel.delegate = self
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return BtcAmountValidator.allowBtcAmountInput(existingInput: textField.text!, addedString: string, replaceRange: range)
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        guard let amount = Double(self.maxBuyAmountLabel.text!) else {
            return
        }
        if amount < 0.0001 {
            return
        }
        
        self.config.buyAmountLimitBtcValue = amount
        self.delegate?.saved(amount: amount)
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    
    @IBOutlet weak var maxBuyAmountLabel: UITextField!
    
    var config: AppConfig!
    var delegate: ChangeBuyAmountLimitDelegate?
}
