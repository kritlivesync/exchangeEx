//
//  ChangePasswordViewController.swift
//  zai
//
//  Created by 渡部郷太 on 1/15/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class ChangePasswordViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
