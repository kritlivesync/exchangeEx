//
//  Position+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 9/9/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Position {

    @NSManaged var id: String
    @NSManaged var tradeLogs: NSOrderedSet
    @NSManaged var trader: Trader

}
