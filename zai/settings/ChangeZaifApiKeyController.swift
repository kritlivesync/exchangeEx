//
//  ChangeZaifApiKeyController.swift
//  zai
//
//  Created by 渡部郷太 on 1/15/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class ChangeZaifApiKeyController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let api = self.zaifExchange.api.rawApi as! PrivateApi
        self.apiKeyLabel.text = api.apiKey
        self.secretKeyLabel.text = api.secretKey
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        let apiKey = self.apiKeyLabel.text!
        let secretKey = self.secretKeyLabel.text!
        let zaifApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        
        var waiting = true
        var success = false
        zaifApi.validateApi() { err in
            if err != nil {
                waiting = false
                return
            }
            guard let ppw = getAccount()?.ppw else {
                waiting = false
                return
            }
            _ = self.zaifExchange.setApiKeys(apiKey: apiKey, secretKey: secretKey, cryptKey: ppw)
            success = true
            waiting = false
        }
        while waiting {
            usleep(20)
        }
        
        if success {
            self.performSegue(withIdentifier: "unwindToSettings", sender: self)
        }
    }
    
    @IBOutlet weak var apiKeyLabel: UITextField!
    @IBOutlet weak var secretKeyLabel: UITextField!
    var zaifExchange: ZaifExchange!
}
