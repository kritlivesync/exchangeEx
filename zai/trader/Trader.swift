//
//  Trader.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData


class Trader: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}


internal class StrongTrader : Trader {
    
    init(name: String, account: Account) {
        super.init(entity: TraderRepository.getInstance().traderDescription, insertIntoManagedObjectContext: nil)
        
        self.name = name
        self.account = account
        self.positions = []
    }
    
}
