//
//  OrdersConfig+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
//
//

import Foundation
import CoreData


extension OrdersConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrdersConfig> {
        return NSFetchRequest<OrdersConfig>(entityName: "OrdersConfig");
    }

    @NSManaged public var orderUpdateInterval: NSNumber
    @NSManaged public var account: Account

}
