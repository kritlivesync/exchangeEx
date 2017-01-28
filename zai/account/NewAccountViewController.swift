//
//  NewAccountViewController.swift
//  zai
//
//  Created by 渡部郷太 on 8/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class NewAccountViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.saveButton.tintColor = Color.antiKeyColor
        self.cancelButton.tintColor = Color.antiKeyColor
        let backButtonItem = UIBarButtonItem(title: "ログイン", style: .plain, target: nil, action: nil)
        backButtonItem.tintColor = Color.antiKeyColor
        self.navigationItem.backBarButtonItem = backButtonItem
        
        // for degug
        self.zaifApiKeyText.text = key_full
        self.zaifSecretKeyText.text = secret_full
        
        self.userIdText.delegate = self
        self.passwordText.delegate = self
        self.passwordAgainText.delegate = self
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case 0:
            return validateUserId(existingInput: textField.text!, addedString: string)
        case 1, 2:
            return validatePassword(existingInput: textField.text!, addedString: string)
        default: return false
        }
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        if self.activeIndicator.isAnimating {
            return
        }
        self.activeIndicator.startAnimating()
        
        let userId = self.userIdText.text!
        if userId == "" {
            self.activeIndicator.stopAnimating()
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.requiredUserIdAndPassword))
            return
        }
        let password = self.passwordText.text!
        if password == "" {
            self.activeIndicator.stopAnimating()
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.requiredUserIdAndPassword))
            return
        }
        if let _ = AccountRepository.getInstance().findByUserId(userId) {
            self.activeIndicator.stopAnimating()
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.userIdAlreadyUsed))
            return
        }
        let passwordAgain = self.passwordAgainText.text!
        if password != passwordAgain {
            self.activeIndicator.stopAnimating()
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.passwordAgainNotMatch))
            return
        }
        
        let apiKey = self.zaifApiKeyText.text!
        let secretKey = self.zaifSecretKeyText.text!
        let zaifApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        zaifApi.validateApi() { err in
            DispatchQueue.main.async {
                let resource = ZaifResource()
                if err == nil {
                    let repository = AccountRepository.getInstance()
                    guard let account = repository.create(userId, password: password) else {
                        self.showError(error: ZaiError(errorType: .UNKNOWN_ERROR, message: Resource.accountCreationFailed))
                        return
                    }
                    guard let exchange = repository.createZaifExchange(account: account, apiKey: apiKey, secretKey: secretKey, nonce: zaifApi.api.nonceValue) else {
                        repository.delete(account)
                        self.showError(error: ZaiError(errorType: .UNKNOWN_ERROR, message: Resource.accountCreationFailed))
                        return
                    }
                    
                    let config = getGlobalConfig()
                    config.previousUserId = userId
                    _ = config.save()
                    
                    self.activeIndicator.stopAnimating()
                    
                    self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
                } else {
                    
                    self.activeIndicator.stopAnimating()
                    
                    switch err!.errorType {
                    case ApiErrorType.NO_PERMISSION:
                        self.showError(error: ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission))
                    case ApiErrorType.NONCE_NOT_INCREMENTED:
                        self.showError(error: ZaiError(errorType: ZaiErrorType.NONCE_NOT_INCREMENTED, message: resource.apiKeyNonceNotIncremented))
                    default:
                        self.showError(error: ZaiError(errorType: .INVALID_API_KEYS, message: resource.invalidApiKey))
                    }
                }
            }
        }
    }

    fileprivate func showError(error: ZaiError) {
        let errorView = createErrorModal(title: error.errorType.toString(), message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }

    
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordAgainText: UITextField!
    
    @IBOutlet weak var zaifApiKeyText: UITextField!
    @IBOutlet weak var zaifSecretKeyText: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!

    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
}
