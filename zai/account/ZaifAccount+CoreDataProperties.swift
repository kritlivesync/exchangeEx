//
//  ZaifAccount+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/1/17.
//
//

import Foundation
import CoreData


extension ZaifAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ZaifAccount> {
        return NSFetchRequest<ZaifAccount>(entityName: "ZaifAccount");
    }

    @NSManaged public var apiKey: String
    @NSManaged public var secretKey: String
    @NSManaged public var nonce: NSNumber

}
