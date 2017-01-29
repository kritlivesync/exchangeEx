//
//  PriceLog+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 9/19/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PriceLog {

    @NSManaged var lastPrice: NSNumber
    @NSManaged var timestamp: NSNumber
    @NSManaged var currencyPair: String

}
