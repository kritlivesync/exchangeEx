//
//  ChartConfig+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


extension ChartConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChartConfig> {
        return NSFetchRequest<ChartConfig>(entityName: "ChartConfig");
    }

    @NSManaged public var chartUpdateInterval: NSNumber
    @NSManaged public var quoteUpdateInterval: NSNumber
    @NSManaged public var selectedCandleChart: NSNumber
    @NSManaged public var account: Account

}
