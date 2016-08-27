//
//  Account+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 8/27/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Account {

    @NSManaged var userId: String
    @NSManaged var traders: Trader

}
