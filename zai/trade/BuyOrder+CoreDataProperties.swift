//
//  BuyOrder+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 12/19/16.
//
//

import Foundation
import CoreData


extension BuyOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BuyOrder> {
        return NSFetchRequest<BuyOrder>(entityName: "BuyOrder");
    }
}
