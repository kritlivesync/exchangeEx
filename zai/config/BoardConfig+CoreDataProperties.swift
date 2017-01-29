//
//  BoardConfig+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


extension BoardConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BoardConfig> {
        return NSFetchRequest<BoardConfig>(entityName: "BoardConfig");
    }

    @NSManaged public var boardUpdateInterval: NSNumber
    @NSManaged public var account: Account

}
