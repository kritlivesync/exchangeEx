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
        
        var waiting = true
        var goNext = false
        
        let api = ZaifSwift.PrivateApi(apiKey: self.apiKeyText.text!, secretKey: self.secretKeyText.text!)
        api.getInfo() { (err, res) in
            if let e = err {
                switch e.errorType {
                case ZSErrorType.INFO_API_NO_PERMISSION:
                    goNext = true
                default: break
                }
            } else {
                goNext = true
            }
            waiting = false
        }
        
        while waiting {
            usleep(20)
        }
        self.api = api
        
        return goNext
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "mainViewSegue" {
            let destController = segue.destinationViewController as! MainViewController
            destController.account = Account(api: self.api!)
        }
    }

    @IBOutlet weak var apiKeyText: UITextField!
    @IBOutlet weak var secretKeyText: UITextField!
    
    private var api: PrivateApi?
}

