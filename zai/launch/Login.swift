//
//  Login.swift
//  zai
//
//  Created by Kyota Watanabe on 12/11/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift


func login(userId: String, password: String, callback: @escaping (_ err: ZaiError?, _ account: Account?) -> Void) {
    guard let account = AccountRepository.getInstance().findByUserIdAndPassword(userId, password: password) else {
        callback(ZaiError(errorType: .LOGIN_ERROR, message: Resource.invalidUserIdOrPassword), nil)
        return
    }
    
    account.activeExchange.validateApiKey() { err in
        account.activeExchange.startWatch()
        callback(err, account)
    }
    
    for ex in account.exchanges {
        let exchange = ex as! Exchange
        if exchange.name != account.activeExchangeName {
            exchange.validateApiKey() { _ in }
        }
    }
}

func loggout() {
    guard let account = getAccount() else {
        return
    }
    
    let app = getApp()
    
    // stop monitoring chart
    for exchange in account.exchanges {
        (exchange as! Exchange).stopWatch()
    }
    
    // stop monitoring trader assets
    account.activeExchange.trader.stopWatch()
    
    account.loggout()
    app.account = nil
    app.resource = createResource(exchangeName: "")
}


func isLogined() -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account != nil
}
