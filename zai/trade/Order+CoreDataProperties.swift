//
//  Order+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 12/25/16.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order");
    }

    @NSManaged public var id: String
    @NSManaged public var status: NSNumber
    @NSManaged public var promisedTime: NSNumber?
    @NSManaged public var promisedPrice: NSNumber?
    @NSManaged public var promisedAmount: NSNumber?
    @NSManaged public var orderPrice: NSNumber?
    @NSManaged public var action: String
    @NSManaged public var orderAmount: NSNumber
    @NSManaged public var orderId: String?
    @NSManaged public var orderTime: NSNumber?
    @NSManaged public var currencyPair: String
    @NSManaged public var position: Position?

}
