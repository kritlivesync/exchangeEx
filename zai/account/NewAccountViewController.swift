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


class NewAccountViewController: UIViewController {
    
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
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        let userId = self.userIdText.text!
        if userId == "" {
            return
        }
        let password = self.passwordText.text!
        if password == "" {
            return
        }
        if let _ = AccountRepository.getInstance().findByUserId(userId) {
            return
        }
        let passwordAgain = self.passwordAgainText.text!
        if password != passwordAgain {
            return
        }
        
        let apiKey = self.zaifApiKeyText.text!
        let secretKey = self.zaifSecretKeyText.text!
        let zaifApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        zaifApi.validateApi() { err in
            if err == nil {
                let repository = AccountRepository.getInstance()
                guard let account = repository.create(userId, password: password) else {
                    return
                }
                guard repository.createZaifExchange(account: account, apiKey: apiKey, secretKey: secretKey) else {
                    repository.delete(account)
                    return
                }
                let app = UIApplication.shared.delegate as! AppDelegate
                app.config.previousUserId = userId
                _ = app.config.save()
                self.performSegue(withIdentifier: "unwindWithSaveSegue", sender: self)
            } else {
                return
            }
        }
    }


    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordAgainText: UITextField!
    
    @IBOutlet weak var zaifApiKeyText: UITextField!
    @IBOutlet weak var zaifSecretKeyText: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!

}
