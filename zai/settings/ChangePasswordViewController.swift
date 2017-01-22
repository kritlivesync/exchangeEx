//
//  ChangePasswordViewController.swift
//  zai
//
//  Created by 渡部郷太 on 1/15/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class ChangePasswordViewController : UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentPassword.delegate = self
        self.newPassword.delegate = self
        self.passwordAgain.delegate = self
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case 0, 1, 2:
            return validatePassword(existingInput: textField.text!, addedString: string)
        default: return false
        }
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        guard let account = getAccount() else {
            return
        }
        guard let password = self.currentPassword.text else {
            return
        }
        if !account.isEqualPassword(password: password) {
            return
        }
        guard let newPw = self.newPassword.text else {
            return
        }
        if password == newPw {
            return
        }
        guard let pwAgain = self.passwordAgain.text else {
            return
        }
        if newPw != pwAgain {
            return
        }
        if let _ = account.setPassword(password: newPw) {
            return
        }
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }

    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordAgain: UITextField!
    
}
