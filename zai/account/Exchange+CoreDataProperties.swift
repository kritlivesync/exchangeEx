//
//  Exchange+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 1/14/17.
//
//

import Foundation
import CoreData


extension Exchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exchange> {
        return NSFetchRequest<Exchange>(entityName: "Exchange");
    }

    @NSManaged public var name: String
    @NSManaged public var currencyPair: String
    @NSManaged public var account: Account
    @NSManaged public var trader: Trader

}
