//
//  AssetsConfig+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
//
//

import Foundation
import CoreData


extension AssetsConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssetsConfig> {
        return NSFetchRequest<AssetsConfig>(entityName: "AssetsConfig");
    }

    @NSManaged public var assetUpdateInterval: NSNumber
    @NSManaged public var account: Account

}
