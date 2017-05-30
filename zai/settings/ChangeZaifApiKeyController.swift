//
//  ChangeZaifApiKeyController.swift
//  zai
//
//  Created by Kyota Watanabe on 1/15/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class ChangeZaifApiKeyController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LabelResource.changeZaifApiKey
        self.navigationItem.leftBarButtonItem?.title = LabelResource.cancel
        self.navigationItem.rightBarButtonItem?.title = LabelResource.save
        
        let api = self.zaifExchange.api.rawApi as! PrivateApi
        self.apiKeyLabel.text = api.apiKey
        self.apiKeyLabel.placeholder = LabelResource.apiKeyPlaceholder
        self.secretKeyLabel.text = api.secretKey
        self.secretKeyLabel.placeholder = LabelResource.secretKeyPlaceholder
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
                    let resource = ZaifResource()
                    switch err!.errorType {
                    case ApiErrorType.NO_PERMISSION:
                        self.showError(error: ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission))
                    case ApiErrorType.NONCE_NOT_INCREMENTED:
                        self.showError(error: ZaiError(errorType: ZaiErrorType.NONCE_NOT_INCREMENTED, message: resource.apiKeyNonceNotIncremented))
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
                _ = self.zaifExchange.setApiKeys(apiKey: apiKey, secretKey: secretKey, nonceValue: zaifApi.api.nonceValue, cryptKey: ppw)
                self.activeIndicator.stopAnimating()
                self.performSegue(withIdentifier: "unwindToSettings", sender: self)
            }
        }
    }
    
    fileprivate func showError(error: ZaiError) {
        let errorView = createErrorModal(title: error.errorType.toString(), message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }
    
    @IBOutlet weak var apiKeyLabel: UITextField!
    @IBOutlet weak var secretKeyLabel: UITextField!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    
    var zaifExchange: ZaifExchange!
}
