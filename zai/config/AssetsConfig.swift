//
//  AssetsConfig+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


public class AssetsConfig: NSManagedObject {

    var assetUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.assetUpdateInterval.intValue)!
        }
        set {
            self.assetUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
}
