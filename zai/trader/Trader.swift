//
//  Trader.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData


public enum TraderState : String {
    case ACTIVE = "active"
    case IDLE = "idle"
}


public class Trader: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(name: String, account: Account) {
        self.init(entity: TraderRepository.getInstance().traderDescription, insertIntoManagedObjectContext: nil)
        
        self.name = name
        self.status = TraderState.ACTIVE.rawValue
        self.account = account
        self.positions = []
    }

}
