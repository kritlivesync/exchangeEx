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

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // for debug
        self.apiKeyText.text = key_full
        self.secretKeyText.text = secret_full
        
        let userId = self.userIdText.text!
        let apiKey = self.apiKeyText.text!
        let secretKey = self.secretKeyText.text!
        
        let api = ZaifSwift.PrivateApi(apiKey: apiKey, secretKey: secretKey)
        let account = AccountRepository.getInstance().findByUserId(userId, api: api)
        if account == nil {
            return false
        }
        
        var waiting = true
        var goNext = false

        account!.validateApiKey() { (err, isValid) in
            if isValid {
                goNext = true
            }
            waiting = false
        }
        
        while waiting {
            usleep(20)
        }
        self.account = account
        
        Config.setPreviousUserId(userId)
        Config.setPreviousApiKey(apiKey)
        Config.setPreviousSecretKey(secretKey)
        Config.save()
        
        return goNext
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch segue.identifier! {
        case self.mainViewSegue:
            let destController = segue.destinationViewController as! MainViewController
            destController.account = account!
        case self.newAccountSegue:
            let destController = segue.destinationViewController as! NewAccountViewController
            destController.delegate = self
        default: break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case self.newAccountLabelTag:
                self.performSegueWithIdentifier(self.newAccountSegue, sender: self)
            default:
                break
            }
        }
    }
    
    func didCreateNewAccount(userId: String) {
        self.userIdFromNewAccount = userId
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var apiKeyText: UITextField!
    @IBOutlet weak var secretKeyText: UITextField!
    
    private let newAccountLabelTag = 0
    private let newAccountSegue = "newAccountSegue"
    private let mainViewSegue = "mainViewSegue"
    
    internal var userIdFromNewAccount = ""
    
    private var account: Account?
}

