//
//  ExchangeAccount+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/1/17.
//
//

import Foundation
import CoreData


extension ExchangeAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeAccount> {
        return NSFetchRequest<ExchangeAccount>(entityName: "ExchangeAccount");
    }

    @NSManaged public var name: String
    @NSManaged public var account: Account
    @NSManaged public var trader: Trader

}
