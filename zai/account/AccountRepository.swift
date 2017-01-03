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
    
    func create(_ userId: String, password: String) -> Account? {
        let db = Database.getDb()
        
        let newAccount = NSEntityDescription.insertNewObject(forEntityName: AccountRepository.accountModelName, into: db.managedObjectContext) as! Account
        newAccount.userId = userId
        newAccount.salt = Crypt.salt()
        newAccount.activeExchangeName = ""
        newAccount.plainPassword = password
        guard newAccount.setPassword(password: password) else {
            return nil
        }

        return newAccount
    }
    
    func delete(_ account: Account) {
        let db = Database.getDb()
        db.managedObjectContext.delete(account)
        db.saveContext()
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
    
    func findByUserIdAndPassword(_ userId: String, password: String) -> Account? {
        guard let account = self.findByUserId(userId) else {
            return nil
        }
        guard let encrypted = Crypt.hash(src: password, salt: account.salt) else {
            return nil
        }
        if encrypted == account.password {
            account.plainPassword = password
            for exchange in account.exchanges {
                let ex = exchange as! Exchange
                guard ex.loadApiKey(password: password) else {
                    return nil
                }
                ex.trader.fund = Fund(api: ex.api)
                ex.trader.fund.delegate = ex.trader
            }
            return account
        } else {
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
    
    func createZaifExchange(account: Account, apiKey: String, secretKey: String) -> Bool {
        let db = Database.getDb()
        
        guard let encryptedApiKey = Crypt.encrypt(key: account.plainPassword!, src: apiKey) else {
            return false
        }
        guard let encryptedSecret = Crypt.encrypt(key: account.plainPassword!, src: secretKey) else {
            return false
        }
        
        let exchange = NSEntityDescription.insertNewObject(forEntityName: AccountRepository.zaifExchangeModelName, into: db.managedObjectContext) as! ZaifExchange
        exchange.name = "zaif"
        exchange.apiKey = NSData(bytes: encryptedApiKey, length: encryptedApiKey.count)
        exchange.secretKey = NSData(bytes: encryptedSecret, length: encryptedSecret.count)
        exchange.serviceApi = ZaifApi(apiKey: apiKey, secretKey: secretKey)
        guard let trader = TraderRepository.getInstance().create("trader", exchange: exchange) else {
            return false
        }
        exchange.trader = trader
        account.addExchange(exchange: exchange)
        
        db.saveContext()
        
        return true
    }
    
    lazy var accountDescription: NSEntityDescription = {
        let db = Database.getDb()
        return NSEntityDescription.entity(forEntityName: AccountRepository.accountModelName, in: db.managedObjectContext)!
    }()
    
    fileprivate init() {
    }
    
    fileprivate static var inst: AccountRepository? = nil
    fileprivate static let accountModelName = "Account"
    fileprivate static let zaifExchangeModelName = "ZaifExchange"
}
