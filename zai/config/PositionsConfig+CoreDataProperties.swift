//
//  PositionsConfig+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


extension PositionsConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PositionsConfig> {
        return NSFetchRequest<PositionsConfig>(entityName: "PositionsConfig");
    }

    @NSManaged public var positionUpdateInterval: NSNumber
    @NSManaged public var account: Account

}
