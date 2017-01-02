//
//  AccountRepository.swift
//  zai
//
//  Created by 渡部郷太 on 8/23/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import CoreData

import ZaifSwift


class AccountRepository {
    
    static func getInstance() -> AccountRepository {
        if let inst = AccountRepository.inst {
            return inst
        } else {
            let inst = AccountRepository()
            AccountRepository.inst = inst
            return inst
        }
    }
    
    func create(_ userId: String, exhange: ExchangeAccount) -> Account {
        let db = Database.getDb()
        
        let newAccount = NSEntityDescription.insertNewObject(forEntityName: AccountRepository.accountModelName, into: db.managedObjectContext) as! Account
        newAccount.userId = userId
        newAccount.activeExchangeName = exhange.name
        let exchanges = newAccount.mutableOrderedSetValue(forKey: "exchanges")
        exchanges.add(exhange)
        newAccount.activeExchangeName = exhange.name
  
        db.saveContext()
        
        return newAccount
    }
    
    func findByUserId(_ userId: String) -> Account? {
        let query: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: AccountRepository.accountModelName)
        let predicate = NSPredicate(format: "userId = %@", userId)
        query.predicate = predicate
        
        let db = Database.getDb()
        do {
            let accounts = try db.managedObjectContext.fetch(query) as! [Account]
            if accounts.count != 1 {
                return nil
            } else {
                let account = accounts[0]
                return account
            }
        } catch {
            return nil
        }
    }
    
    func count() -> Int {
        let query: NSFetchRequest<Account> = Account.fetchRequest()
        
        let db = Database.getDb()
        do {
            let accounts = try db.managedObjectContext.fetch(query)
            return accounts.count
        } catch {
            return 0
        }
    }
    
    lazy var accountDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: AccountRepository.accountModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: AccountRepository? = nil
    fileprivate static let accountModelName = "Account"
}
