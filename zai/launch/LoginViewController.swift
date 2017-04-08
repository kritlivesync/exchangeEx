//
//  ViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 6/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import UIKit

import ZaifSwift

class LoginViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = Color.keyColor
        self.navigationBar.items?[0].title = LabelResource.loginViewTitle
        self.navigationBar.delegate = self
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.navigationBar.frame = self.navigationBar.frame.offsetBy(dx: 0.0, dy: statusBarHeight)
        
        self.loginButton.setTitle(LabelResource.login, for: UIControlState.normal)
        self.loginButton.tintColor = UIColor.white
        self.loginButton.layer.borderWidth = 1.0
        self.loginButton.layer.borderColor = Color.keyColor.cgColor
        self.loginButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
        
        self.newAccountButton.setTitleColor(Color.keyColor, for: UIControlState.normal)
        self.newAccountButton.setTitle(LabelResource.createNewAccount, for: UIControlState.normal)
        
        self.userIdText.placeholder = LabelResource.loginUserIdPlaceholder
        self.userIdText.delegate = self
        self.passwordText.placeholder = LabelResource.loginPasswordPlaceholder
        self.passwordText.delegate = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userIdText.text = getGlobalConfig().previousUserId
        self.passwordText.text = ""
    }
    
    @IBAction func pushLoginButton(_ sender: Any) {
        if self.activeIndicator.isAnimating {
            return
        }
        self.activeIndicator.startAnimating()
        
        let userId = self.userIdText.text!
        let password = self.passwordText.text!
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        login(userId: userId, password: password) { (err, account) in
            DispatchQueue.main.async {
                app.account = account
                if let e = err {
                    self.activeIndicator.stopAnimating()
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message) { action in
                        if e.errorType == .INVALID_API_KEYS_NO_PERMISSION ||
                           e.errorType == .NONCE_NOT_INCREMENTED ||
                           e.errorType == .INVALID_API_KEYS {
                            self.performSegue(withIdentifier: self.mainViewSegue, sender: nil)
                        }
                    }
                    self.present(errorView, animated: false, completion: nil)
                } else {
                    self.activeIndicator.stopAnimating()
                    self.performSegue(withIdentifier: self.mainViewSegue, sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.mainViewSegue {
            let app = UIApplication.shared.delegate as! AppDelegate
            let account = getAccount()!
            app.resource = createResource(exchangeName: account.activeExchange.name)
            let config = getGlobalConfig()
            config.previousUserId = account.userId
            _ = config.save()
        }
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
        self.userIdText.text = getGlobalConfig().previousUserId
    }
    
    
    func didCreateNewAccount(_ userId: String) {
        self.userIdFromNewAccount = userId
    }

    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!

    fileprivate let newAccountLabelTag = 0
    fileprivate let newAccountSegue = "newAccountSegue"
    fileprivate let mainViewSegue = "mainTabSegue"
    
    internal var userIdFromNewAccount = ""
    
    fileprivate var account: Account?
}

