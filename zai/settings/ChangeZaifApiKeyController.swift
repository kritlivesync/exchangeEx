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
        if self.activeIndicator.isAnimating {
            return
        }
        self.activeIndicator.startAnimating()
        
        let apiKey = self.apiKeyLabel.text!
        let secretKey = self.secretKeyLabel.text!
        let zaifApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        
        zaifApi.validateApi() { err in
            DispatchQueue.main.async {
                if err != nil {
                    self.activeIndicator.stopAnimating()
                    return
                }
                guard let ppw = getAccount()?.ppw else {
                    self.activeIndicator.stopAnimating()
                    return
                }
                _ = self.zaifExchange.setApiKeys(apiKey: apiKey, secretKey: secretKey, nonceValue: zaifApi.api.nonceValue, cryptKey: ppw)
                self.activeIndicator.stopAnimating()
                self.performSegue(withIdentifier: "unwindToSettings", sender: self)
            }
        }
    }
    
    @IBOutlet weak var apiKeyLabel: UITextField!
    @IBOutlet weak var secretKeyLabel: UITextField!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    
    var zaifExchange: ZaifExchange!
}
