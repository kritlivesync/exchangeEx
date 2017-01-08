//
//  ViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

import ZaifSwift

class LoginViewController: UIViewController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.tintColor = UIColor.white
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = Color.keyColor.cgColor
        self.loginButton.titleLabel?.textColor = Color.keyColor
        self.navigationBar.delegate = self
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.navigationBar.frame = self.navigationBar.frame.offsetBy(dx: 0.0, dy: statusBarHeight)
        
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
    
    // UIBarPositioningDelegate
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
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
    @IBOutlet weak var navigationBar: UINavigationBar!

    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}
