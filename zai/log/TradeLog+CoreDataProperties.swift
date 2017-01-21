//
//  TradeLog+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/22/17.
//
//

import Foundation
import CoreData


extension TradeLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TradeLog> {
        return NSFetchRequest<TradeLog>(entityName: "TradeLog");
    }

    @NSManaged public var amount: NSNumber?
    @NSManaged public var currencyPair: String?
    @NSManaged public var id: String
    @NSManaged public var orderAction: String?
    @NSManaged public var orderId: String?
    @NSManaged public var positionId: String?
    @NSManaged public var price: NSNumber?
    @NSManaged public var timestamp: NSNumber
    @NSManaged public var tradeAction: String
    @NSManaged public var traderName: String
    @NSManaged public var userId: String
    @NSManaged public var position: Position?

}
