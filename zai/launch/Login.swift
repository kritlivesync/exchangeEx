//
//  Login.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


func login(userId: String, password: String, callback: @escaping (_ err: ZaiError?, _ account: Account?) -> Void) {
    guard let account = AccountRepository.getInstance().findByUserId(userId) else {
        callback(ZaiError(errorType: .INVALID_ACCOUNT_INFO), nil)
        return
    }

    guard let cryptPass = hash(src: password, salt: account.salt) else {
        callback(ZaiError(errorType: .UNKNOWN_ERROR), nil)
        return
    }
    
    if cryptPass != account.password {
        callback(ZaiError(errorType: .INVALID_ACCOUNT_INFO), nil)
        return
    }
    
    account.activeExchange.validateApiKey() { err in
        callback(err, account)
    }
}

func isLogined() -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account != nil
}

func getAccount() -> Account? {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account
}
