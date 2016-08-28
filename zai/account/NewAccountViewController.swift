//
//  NewAccountViewController.swift
//  zai
//
//  Created by 渡部郷太 on 8/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import UIKit

import ZaifSwift


@objc protocol NewAccountViewDelegate {
    func didCreateNewAccount(userId: String)
}


class NewAccountViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func pushCreateButton(sender: AnyObject) {
        let userId = self.userIdText.text!
        if userId == "" {
            self.errorMessageLabel.text = "Invalid user id"
            return
        }
        
        let repository = AccountRepository.getInstance()
        let dummyApi = PrivateApi(apiKey: "", secretKey: "")
        let account = repository.findByUserId(userId, api: dummyApi)
        if let _ = account {
            self.errorMessageLabel.text = "User id already exists"
            return
        }
        
        repository.create(userId, api: dummyApi)
        
        self.performSegueWithIdentifier("backToLoginSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let ident = segue.identifier {
            switch ident {
            case "backToLoginSegue":
                let destController = segue.destinationViewController as! LoginViewController
                destController.userIdFromNewAccount = self.userIdText.text!
            default: break
            }
        }
    }
    
    @IBAction func back(segue:UIStoryboardSegue) {
        print("bbb")
    }
    
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    weak var delegate: NewAccountViewDelegate?
}
