//
//  AppConfig+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/28/17.
//
//

import Foundation
import CoreData


extension AppConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppConfig> {
        return NSFetchRequest<AppConfig>(entityName: "AppConfig");
    }

    @NSManaged public var buyAmountLimitBtc: NSNumber
    @NSManaged public var footerUpdateInterval: NSNumber
    @NSManaged public var unwindingRule: NSNumber
    @NSManaged public var account: Account

}
