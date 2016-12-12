//
//  Login.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


func login(userId: String, apiKey: String, secretKey: String, callback: @escaping (_ err: ZaiErrorType?, _ account: Account?) -> Void) {
    
    let nonce = TimeNonce()
    let api = ZaifSwift.PrivateApi(apiKey: apiKey, secretKey: secretKey, nonce: nonce)
    let account = AccountRepository.getInstance().findByUserId(userId, api: api)
    if account == nil {
        callback(ZaiErrorType.INVALID_ACCOUNT_INFO, nil)
        return
    }
    
    api.searchValidNonce() { valid in
        account!.validateApiKey() { (err, isValid) in
            if isValid {
                callback(nil, account)
            } else {
                callback(ZaiErrorType.INVALID_API_KEYS, nil)
            }
        }
    }
}
