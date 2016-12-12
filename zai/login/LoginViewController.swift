//
//  ViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

import ZaifSwift

class LoginViewController: UIViewController, NewAccountViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userIdText.text = Config.previousUserId
        self.apiKeyText.text = Config.previousApiKey
        self.secretKeyText.text = Config.previousSecretKey
        
        if !self.userIdFromNewAccount.isEmpty {
            self.userIdText.text = self.userIdFromNewAccount
            self.userIdFromNewAccount = ""
            self.apiKeyText.text = ""
            self.secretKeyText.text = ""
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // for debug
        self.apiKeyText.text = key_full
        self.secretKeyText.text = secret_full
        
        let userId = self.userIdText.text!
        let apiKey = self.apiKeyText.text!
        let secretKey = self.secretKeyText.text!
        
        var waiting = true
        var goNext = false

        login(userId: userId, apiKey: apiKey, secretKey: secretKey) { (err, account) in
            if let _ = err {
                self.errorMessageLabel.text = "invalid user name or api keys"
                goNext = false
            } else {
                self.account = account
                goNext = true
            }
            waiting = false
        }
        
        while waiting {
            usleep(20)
        }
        
        if goNext {
            let traderName = "dummyTrader"
            let repository = TraderRepository.getInstance()
            let trader = repository.findTraderByName(traderName, api: (self.account?.privateApi)!)
            if trader == nil {
                repository.create(traderName, account: account!)
                Config.SetCurrentTraderName(traderName)
            }
            
            Config.setPreviousUserId(userId)
            Config.setPreviousApiKey(apiKey)
            Config.setPreviousSecretKey(secretKey)
            Config.save()
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.analyzer = Analyzer(api: (self.account?.privateApi)!)
            UIApplication.shared.isIdleTimerDisabled = true
        }

        return goNext
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        switch segue.identifier! {
        case self.mainViewSegue:
            let destController = segue.destination as! MainTabBarController
            destController.account = account!
            
        case self.newAccountSegue:
            let destController = segue.destination as! NewAccountViewController
            destController.delegate = self
        default: break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case self.newAccountLabelTag:
                self.performSegue(withIdentifier: self.newAccountSegue, sender: self)
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {}
    
    func didCreateNewAccount(_ userId: String) {
        self.userIdFromNewAccount = userId
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var apiKeyText: UITextField!
    @IBOutlet weak var secretKeyText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}

