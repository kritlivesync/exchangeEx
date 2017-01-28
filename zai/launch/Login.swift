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
    guard let account = AccountRepository.getInstance().findByUserIdAndPassword(userId, password: password) else {
        callback(ZaiError(errorType: .LOGIN_ERROR, message: Resource.invalidUserIdOrPassword), nil)
        return
    }
    
    account.activeExchange.validateApiKey() { err in
        callback(err, account)
    }
}

func loggout() {
    guard let account = getAccount() else {
        return
    }
    account.loggout()
    let app = UIApplication.shared.delegate as! AppDelegate
    app.account = nil
    app.resource = createResource(exchangeName: "")
}


func isLogined() -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account != nil
}
