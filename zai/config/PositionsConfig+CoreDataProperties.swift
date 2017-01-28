//
//  PositionsConfig+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
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
