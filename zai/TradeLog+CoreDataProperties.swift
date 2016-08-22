//
//  TradeLog+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TradeLog {

    @NSManaged var id: String
    @NSManaged var userId: String
    @NSManaged var apiKey: String
    @NSManaged var positionId: String
    @NSManaged var traderName: String
    @NSManaged var tradeAction: String
    @NSManaged var orderAction: String
    @NSManaged var currencyPair: String
    @NSManaged var price: NSNumber
    @NSManaged var amount: NSNumber
    @NSManaged var timestamp: NSNumber

}
