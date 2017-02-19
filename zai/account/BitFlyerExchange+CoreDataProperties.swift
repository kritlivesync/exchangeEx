//
//  BitFlyerExchange+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 2/17/17.
//
//

import Foundation
import CoreData


extension BitFlyerExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BitFlyerExchange> {
        return NSFetchRequest<BitFlyerExchange>(entityName: "BitFlyerExchange");
    }

    @NSManaged public var apiKey: NSData
    @NSManaged public var secretKey: NSData

}
