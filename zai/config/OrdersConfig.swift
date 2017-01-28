//
//  OrdersConfig+CoreDataClass.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
//
//

import Foundation
import CoreData


public class OrdersConfig: NSManagedObject {

    var orderUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.orderUpdateInterval.intValue)!
        }
        set {
            self.orderUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
}
