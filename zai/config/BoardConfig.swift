//
//  BoardConfig+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
//
//

import Foundation
import CoreData


public class BoardConfig: NSManagedObject {

    var boardUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.boardUpdateInterval.intValue)!
        }
        set {
            self.boardUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
}
