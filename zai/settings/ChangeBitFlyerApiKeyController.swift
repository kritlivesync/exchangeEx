//
//  ChangeBitFlyerApiKeyController.swift
//  zai
//
//  Created by 渡部郷太 on 2/25/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import bFSwift


class ChangeBitFlyerApiKeyController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let api = self.exchange.api.rawApi as! PrivateApi
        self.apiKeyText.text = api.apiKey
        self.secretKeyText.text = api.secretKey
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        if self.activeIndicator.isAnimating {
            return
        }
        self.activeIndicator.startAnimating()
        
        let apiKey = self.apiKeyText.text!
        let secretKey = self.secretKeyText.text!
        let api = bitFlyerApi(apiKey: apiKey, secretKey: secretKey)
        
        api.validateApi() { err in
            DispatchQueue.main.async {
                if err != nil {
                    self.activeIndicator.stopAnimating()
                    let resource = bitFlyerResource()
                    switch err!.errorType {
                    case ApiErrorType.NO_PERMISSION:
                        self.showError(error: ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission))
                    case ApiErrorType.CONNECTION_ERROR:
                        self.showError(error: ZaiError(errorType: ZaiErrorType.CONNECTION_ERROR, message: Resource.networkConnectionError))
                    default:
                        self.showError(error: ZaiError(errorType: .INVALID_API_KEYS, message: resource.invalidApiKey))
                    }
                    return
                }
                guard let ppw = getAccount()?.ppw else {
                    self.activeIndicator.stopAnimating()
                    return
                }
                _ = self.exchange.setApiKeys(apiKey: apiKey, secretKey: secretKey, cryptKey: ppw)
                self.activeIndicator.stopAnimating()
                self.performSegue(withIdentifier: "unwindToSettings", sender: self)
            }
        }
    }
    
    fileprivate func showError(error: ZaiError) {
        let errorView = createErrorModal(title: error.errorType.toString(), message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }
    
    @IBOutlet weak var apiKeyText: UITextField!
    @IBOutlet weak var secretKeyText: UITextField!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    
    var exchange: BitFlyerExchange!
}
