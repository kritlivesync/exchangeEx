//
//  ZaifExchange+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/3/17.
//
//

import Foundation
import CoreData


extension ZaifExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZaifExchange> {
        return NSFetchRequest<ZaifExchange>(entityName: "ZaifExchange");
    }

    @NSManaged public var apiKey: NSData
    @NSManaged public var nonce: NSNumber
    @NSManaged public var secretKey: NSData

}
