//
//  BitFlyerExchange+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 2/17/17.
//
//

import Foundation
import CoreData

import bFSwift


public class BitFlyerExchange: Exchange {

    override func validateApiKey(_ cb: @escaping (ZaiError?) -> Void) {
        self.serviceApi?.validateApi() { err in
            if err != nil {
                let resource = createResource(exchangeName: self.name)
                switch err!.errorType {
                case ApiErrorType.NO_PERMISSION:
                    cb(ZaiError(errorType: .INVALID_API_KEYS_NO_PERMISSION, message: resource.apiKeyNoPermission))
                case ApiErrorType.NONCE_NOT_INCREMENTED:
                    cb(ZaiError(errorType: ZaiErrorType.NONCE_NOT_INCREMENTED, message: resource.apiKeyNonceNotIncremented))
                case ApiErrorType.INVALID_API_KEY:
                    cb(ZaiError(errorType: ZaiErrorType.INVALID_API_KEYS, message: resource.invalidApiKeyRestricted))
                case ApiErrorType.CONNECTION_ERROR:
                    cb(ZaiError(errorType: ZaiErrorType.CONNECTION_ERROR, message: Resource.networkConnectionError))
                default:
                    cb(ZaiError(errorType: .INVALID_API_KEYS, message: Resource.unknownError))
                }
            } else {
                cb(nil)
            }
        }
    }
    
    override func loadApiKey(cryptKey: String) -> Bool {
        guard let apiKey = Crypt.decrypt(key: cryptKey, src: self.apiKey.toBytes()) else {
            return false
        }
        guard let secretKey = Crypt.decrypt(key: cryptKey, src: self.secretKey.toBytes()) else {
            return false
        }
        let api = bitFlyerApi(apiKey: apiKey, secretKey: secretKey)
        self.serviceApi = api
        return true
    }
    
    override func saveApiKey(cryptKey: String) -> Bool {
        let rawApi = self.serviceApi?.rawApi as! PrivateApi
        guard let encryptedApiKey = Crypt.encrypt(key: cryptKey, src: rawApi.apiKey) else {
            return false
        }
        guard let encryptedSecret = Crypt.encrypt(key: cryptKey, src: rawApi.secretKey) else {
            return false
        }
        self.apiKey = NSData(bytes: encryptedApiKey, length: encryptedApiKey.count)
        self.secretKey = NSData(bytes: encryptedSecret, length: encryptedSecret.count)
        Database.getDb().saveContext()
        return true
    }
    
    func setApiKeys(apiKey: String, secretKey: String, cryptKey: String) -> Bool {
        let api = bitFlyerApi(apiKey: apiKey, secretKey: secretKey)
        self.serviceApi = api
        
        if !self.saveApiKey(cryptKey: cryptKey) {
            return false
        }
        return true
    }
    
    override var handlingCurrencyPairs: [ApiCurrencyPair] {
        return [.BTC_JPY]
    }
    
    override var displayCurrencyPair: String {
        switch self.currencyPair {
        case "btc_jpy": return "BTC/JPY"
        default: return ""
        }
    }
}
