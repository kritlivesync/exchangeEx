//
//  SellOrder+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 12/19/16.
//
//

import Foundation
import CoreData


extension SellOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SellOrder> {
        return NSFetchRequest<SellOrder>(entityName: "SellOrder");
    }


}
