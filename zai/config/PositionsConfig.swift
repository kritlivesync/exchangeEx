//
//  PositionsConfig+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


public class PositionsConfig: NSManagedObject {

    var positionUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.positionUpdateInterval.intValue)!
        }
        set {
            self.positionUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
}
