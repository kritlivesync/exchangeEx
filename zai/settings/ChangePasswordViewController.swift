//
//  ChangePasswordViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 1/15/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


class ChangePasswordViewController : UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LabelResource.changePassword
        self.navigationItem.leftBarButtonItem?.title = LabelResource.cancel
        self.navigationItem.rightBarButtonItem?.title = LabelResource.save
        
        self.currentPassword.placeholder = LabelResource.currentPasswordPlaceholder
        self.newPassword.placeholder = LabelResource.newPasswordPlaceholder
        self.passwordAgain.placeholder = LabelResource.passwordAgainPlaceholder
        
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
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.invalidPassword))
            return
        }
        guard let newPw = self.newPassword.text else {
            return
        }
        if validatePassword(password: newPw) == false {
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.invalidPasswordLength))
            return
        }
        if password == newPw {
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.passwordSameAsCurrent))
            return
        }
        guard let pwAgain = self.passwordAgain.text else {
            return
        }
        if newPw != pwAgain {
            self.showError(error: ZaiError(errorType: .INVALID_ACCOUNT_INFO, message: Resource.passwordAgainNotMatch))
            return
        }
        if let _ = account.setPassword(password: newPw) {
            return
        }
        self.performSegue(withIdentifier: "unwindToSettings", sender: self)
    }
    
    fileprivate func showError(error: ZaiError) {
        let errorView = createErrorModal(message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }

    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordAgain: UITextField!
    
}
