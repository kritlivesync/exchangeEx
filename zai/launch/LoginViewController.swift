//
//  ViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import UIKit

import ZaifSwift

class LoginViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = Color.keyColor
        
        self.loginButton.tintColor = UIColor.white
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = Color.keyColor.cgColor
        self.loginButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
        self.newAccountButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
        self.navigationBar.delegate = self
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.navigationBar.frame = self.navigationBar.frame.offsetBy(dx: 0.0, dy: statusBarHeight)
        
        self.userIdText.text = getAppConfig().previousUserId
        self.passwordText.text = ""
        
        self.userIdText.delegate = self
        self.passwordText.delegate = self
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
            let config = getAppConfig()
            config.previousUserId = userId
            _ = config.save()
        }

        return goNext
    }
    
    // UIBarPositioningDelegate
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case 0:
            return validateUserId(existingInput: textField.text!, addedString: string)
        case 1:
            return validatePassword(existingInput: textField.text!, addedString: string)
        default: return false
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {}
    
    @IBAction func unwindWithSave(_ segue:UIStoryboardSegue) {
        self.userIdText.text = getAppConfig().previousUserId
    }
    
    
    func didCreateNewAccount(_ userId: String) {
        self.userIdFromNewAccount = userId
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!

    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}

