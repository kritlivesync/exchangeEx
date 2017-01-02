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
        
        self.loginButton.tintColor = Color.keyColor
        
        let app = UIApplication.shared.delegate as! AppDelegate
        self.userIdText.text = app.config.previousUserId
        self.passwordText.text = ""
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // for debug
        //self.apiKeyText.text = key_full
        //self.secretKeyText.text = secret_full
        
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
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}

