//
//  ZaifAccount+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 1/1/17.
//
//

import Foundation
import CoreData

import ZaifSwift

extension NSData {
    func toBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: self.length)
        self.getBytes(&bytes, length: self.length)
        return bytes
    }
}

public class ZaifExchange: Exchange, ZaiApiDelegate {
    
    override func validateApiKey(_ cb: @escaping (ZaiError?) -> Void) {
        self.serviceApi?.validateApi() { err in
            if err != nil {
                let resource = createResource(exchangeName: self.name)
                _ = self.saveApiKey(cryptKey: self.account.ppw!) // save nonce
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
        let nonce = TimeNonce(initialValue: self.nonce.int64Value)
        let api = ZaifApi(apiKey: apiKey, secretKey: secretKey, nonce: nonce)
        api.delegate = self
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
        self.nonce = (self.serviceApi?.rawApi as! PrivateApi).nonceValue as NSNumber
        Database.getDb().saveContext()
        return true
    }
    
    func setApiKeys(apiKey: String, secretKey: String, nonceValue: Int64, cryptKey: String) -> Bool {
        let nonce = TimeNonce(initialValue: nonceValue)
        let api = ZaifApi(apiKey: apiKey, secretKey: secretKey, nonce: nonce)
        api.delegate = self
        self.serviceApi = api
        
        if !self.saveApiKey(cryptKey: cryptKey) {
            return false
        }
        return true
    }
    
    // ZaiApiDelegate
    func privateApiCalled(apiName: String) {
        DispatchQueue.main.async {
            guard let nonce = (self.serviceApi?.rawApi as? PrivateApi)?.nonceValue else {
                return
            }
            self.nonce = NSNumber(value: nonce)
        }
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
    
    override var api: Api {
        get {
            return self.serviceApi!
        }
    }
}
