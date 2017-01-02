//
//  ZaifAccount+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 1/1/17.
//
//

import Foundation
import CoreData

import ZaifSwift


public class ZaifAccount: ExchangeAccount {

    override func validateApiKey(_ cb: @escaping (ZaiError?) -> Void) {
        let rawApi = self.api.rawApi as! PrivateApi
        rawApi.searchValidNonce() { err in
            if err != nil {
                cb(ZaiError(errorType: .INVALID_API_KEYS, message: err!.message))
            } else {
                cb(nil)
            }
        }
    }
    
    override var api: Api {
        get {
            guard let api = self.serviceApi else {
                let nonce = TimeNonce()
                self.serviceApi = ZaifApi(apiKey: self.apiKey, secretKey: self.secretKey, nonce: nonce)
                return self.serviceApi!
            }
            return api
        }
    }
}
