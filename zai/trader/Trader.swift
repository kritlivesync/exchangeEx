//
//  Trader.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData


public class Trader: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}


public class StrongTrader : Trader {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(name: String, account: Account) {
        self.init(entity: TraderRepository.getInstance().traderDescription, insertIntoManagedObjectContext: Database.getDb().managedObjectContext)
        
        self.name = name
        self.account = account
        self.positions = []
    }
    
}
