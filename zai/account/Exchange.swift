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
    func loadApiKey(password: String) -> Bool
    func saveApiKey(password: String) -> Bool
    
    var api: Api { get }
}

public class Exchange: NSManagedObject, ExchangeProtocol {
    
    func validateApiKey(_ callback: @escaping (ZaiError?) -> Void) {
        callback(ZaiError(errorType: .UNKNOWN_ERROR))
    }
    
    func loadApiKey(password: String) -> Bool {
        return false
    }
    
    func saveApiKey(password: String) -> Bool {
        return false
    }

    var api: Api {
        get { return self.serviceApi! }
    }
    
    var serviceApi: Api?
}
