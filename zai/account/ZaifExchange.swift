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

extension NSData {
    func toBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: self.length)
        self.getBytes(&bytes, length: self.length)
        return bytes
    }
}

public class ZaifExchange: Exchange, ZaiApiDelegate {

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
    
    override func loadApiKey(password: String) -> Bool {
        guard let apiKey = Crypt.decrypt(key: password, src: self.apiKey.toBytes()) else {
            return false
        }
        guard let secretKey = Crypt.decrypt(key: password, src: self.secretKey.toBytes()) else {
            return false
        }
        let nonce = TimeNonce(initialValue: self.nonce.int64Value)
        let api = ZaifApi(apiKey: apiKey, secretKey: secretKey, nonce: nonce)
        api.delegate = self
        self.serviceApi = api
        return true
    }
    
    override func saveApiKey(password: String) -> Bool {
        let rawApi = self.serviceApi?.rawApi as! PrivateApi
        guard let encryptedApiKey = Crypt.encrypt(key: password, src: rawApi.apiKey) else {
            return false
        }
        guard let encryptedSecret = Crypt.encrypt(key: password, src: rawApi.secretKey) else {
            return false
        }
        self.apiKey = NSData(bytes: encryptedApiKey, length: encryptedApiKey.count)
        self.secretKey = NSData(bytes: encryptedSecret, length: encryptedSecret.count)
        self.nonce = (self.serviceApi?.rawApi as! PrivateApi).nonceValue as NSNumber
        Database.getDb().saveContext()
        return true
    }
    
    // ZaiApiDelegate
    func privateApiCalled(apiName: String) {
        self.nonce = (self.serviceApi?.rawApi as! PrivateApi).nonceValue as NSNumber
    }
    
    override var api: Api {
        get {
            return self.serviceApi!
        }
    }
}
