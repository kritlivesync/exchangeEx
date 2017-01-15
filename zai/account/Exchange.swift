//
//  ExchangeAccount+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 1/1/17.
//
//

import Foundation
import CoreData

import ZaifSwift


protocol ExchangeProtocol {
    func validateApiKey(_ cb: @escaping (ZaiError?) -> Void)
    func loadApiKey(cryptKey: String) -> Bool
    func saveApiKey(cryptKey: String) -> Bool
    func reEncryptApiKey(oldCryptKey: String, newCryptKey: String) -> Bool
    
    var handlingCurrencyPairs: [ApiCurrencyPair] { get }
    var displayCurrencyPair: String { get }
    var api: Api { get }
}

public class Exchange: NSManagedObject, ExchangeProtocol {
    
    func validateApiKey(_ callback: @escaping (ZaiError?) -> Void) {
        callback(ZaiError(errorType: .UNKNOWN_ERROR))
    }
    
    func loadApiKey(cryptKey: String) -> Bool {
        return false
    }
    
    func saveApiKey(cryptKey: String) -> Bool {
        return false
    }
    
    func reEncryptApiKey(oldCryptKey: String, newCryptKey: String) -> Bool {
        return true
    }
    
    var handlingCurrencyPairs: [ApiCurrencyPair] {
        return [ApiCurrencyPair]()
    }
    
    var displayCurrencyPair: String {
        return ""
    }

    var api: Api {
        return self.serviceApi!
    }
    
    var apiCurrencyPair: ApiCurrencyPair {
        return ApiCurrencyPair(rawValue: self.currencyPair)!
    }
    
    var serviceApi: Api?
}
