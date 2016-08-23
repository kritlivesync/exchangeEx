//
//  ViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

import ZaifSwift

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // for debug
        self.apiKeyText.text = key_full
        self.secretKeyText.text = secret_full
        
        if self.apiKeyText.text!.isEmpty || self.secretKeyText.text!.isEmpty {
            return false
        }
        
        let api = ZaifSwift.PrivateApi(apiKey: self.apiKeyText.text!, secretKey: self.secretKeyText.text!)
        let account = AccountRepository.getInstance().findByUserId(self.userIdText.text!, api: api)
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
        
        return goNext
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "mainViewSegue" {
            let destController = segue.destinationViewController as! MainViewController
            destController.account = account!
        }
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var apiKeyText: UITextField!
    @IBOutlet weak var secretKeyText: UITextField!
    
    private var account: Account?
}

