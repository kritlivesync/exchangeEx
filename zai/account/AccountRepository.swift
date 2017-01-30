//
//  AccountRepository.swift
//  zai
//
//  Created by Kyota Watanabe on 8/23/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
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
        newAccount.ppw = password
        if let _ =  newAccount.setPassword(password: password) {
            return nil
        }
        
        _ = ConfigRepository.getInstance().create(account: newAccount)

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
            account.ppw = password
            for exchange in account.exchanges {
                let ex = exchange as! Exchange
                guard ex.loadApiKey(cryptKey: password) else {
                    return nil
                }
                ex.trader.fund = Fund(api: ex.api)
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
    
    func createZaifExchange(account: Account, apiKey: String, secretKey: String, nonce: Int64=0) -> ZaifExchange? {
        let db = Database.getDb()
        
        guard let encryptedApiKey = Crypt.encrypt(key: account.ppw!, src: apiKey) else {
            return nil
        }
        guard let encryptedSecret = Crypt.encrypt(key: account.ppw!, src: secretKey) else {
            return nil
        }
        
        let exchange = NSEntityDescription.insertNewObject(forEntityName: AccountRepository.zaifExchangeModelName, into: db.managedObjectContext) as! ZaifExchange
        exchange.name = "Zaif"
        exchange.currencyPair = ApiCurrencyPair.BTC_JPY.rawValue
        exchange.apiKey = NSData(bytes: encryptedApiKey, length: encryptedApiKey.count)
        exchange.secretKey = NSData(bytes: encryptedSecret, length: encryptedSecret.count)
        exchange.nonce = NSNumber(value: nonce)
        let api = ZaifApi(apiKey: apiKey, secretKey: secretKey, nonce: TimeNonce(initialValue: nonce))
        api.delegate = exchange
        exchange.serviceApi = api
        guard let trader = TraderRepository.getInstance().create("trader", exchange: exchange) else {
            return nil
        }
        exchange.trader = trader
        account.addExchange(exchange: exchange)
        
        db.saveContext()
        
        return exchange
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
