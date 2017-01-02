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


protocol ExchangeAccountProtocol {
    func validateApiKey(_ cb: @escaping (ZaiError?) -> Void)
    
    var api: Api { get }
}

public class ExchangeAccount: NSManagedObject, ExchangeAccountProtocol {
    
    func validateApiKey(_ callback: @escaping (ZaiError?) -> Void) {
        callback(ZaiError(errorType: .UNKNOWN_ERROR))
    }

    var api: Api {
        get { return self.serviceApi! }
    }
    
    var serviceApi: Api?
}
