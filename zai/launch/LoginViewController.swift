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
        
        self.loginButton.tintColor = Color.keyColor
        
        let app = UIApplication.shared.delegate as! AppDelegate
        self.userIdText.text = app.config.previousUserId
        self.passwordText.text = ""
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == self.newAccountSegue {
            return true
        }
        
        let userId = self.userIdText.text!
        let password = self.passwordText.text!
        
        var waiting = true
        var goNext = false
        
        let app = UIApplication.shared.delegate as! AppDelegate

        login(userId: userId, password: password) { (err, account) in
            if let _ = err {
                goNext = false
            } else {
                app.account = account
                goNext = true
            }
            waiting = false
        }
        
        while waiting {
            usleep(20)
        }
        
        if goNext {
            app.config.previousUserId = userId
            _ = app.config.save()
        }

        return goNext
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {}
    
    @IBAction func unwindWithSave(_ segue:UIStoryboardSegue) {
        let app = UIApplication.shared.delegate as! AppDelegate
        self.userIdText.text = app.config.previousUserId
    }
    
    
    func didCreateNewAccount(_ userId: String) {
        self.userIdFromNewAccount = userId
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}

