//
//  Trader+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Trader {

    @NSManaged var name: String
    @NSManaged var account: Account
    @NSManaged var positions: NSSet

}
