//
//  ConfigRepository.swift
//  zai
//
//  Created by 渡部郷太 on 1/28/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import CoreData



class ConfigRepository {
    
    static func getInstance() -> ConfigRepository {
        if let inst = ConfigRepository.inst {
            return inst
        } else {
            let inst = ConfigRepository()
            ConfigRepository.inst = inst
            return inst
        }
    }
    
    func create(account: Account) -> Account? {
        let db = Database.getDb()
        
        let appConfig = NSEntityDescription.insertNewObject(forEntityName: "AppConfig", into: db.managedObjectContext) as! AppConfig
        appConfig.buyAmountLimitBtc = 1.0
        appConfig.footerUpdateInterval = UpdateInterval.tenSeconds.rawValue as NSNumber
        appConfig.unwindingRule = UnwindingRule.mostBenefit.rawValue as NSNumber
        appConfig.languageType = getGlobalConfig().language
        account.appConfig = appConfig
        
        let assetsConfig = NSEntityDescription.insertNewObject(forEntityName: "AssetsConfig", into: db.managedObjectContext) as! AssetsConfig
        assetsConfig.assetUpdateInterval = UpdateInterval.thirtySeconds.rawValue as NSNumber
        account.assetsConfig = assetsConfig
        
        let chartConfig = NSEntityDescription.insertNewObject(forEntityName: "ChartConfig", into: db.managedObjectContext) as! ChartConfig
        chartConfig.chartUpdateInterval = UpdateInterval.fiveSeconds.rawValue as NSNumber
        chartConfig.quoteUpdateInterval = UpdateInterval.fiveSeconds.rawValue as NSNumber
        chartConfig.selectedCandleChart = ChandleChartType.oneMinute.rawValue as NSNumber
        account.chartConfig = chartConfig
        
        let boardConfig = NSEntityDescription.insertNewObject(forEntityName: "BoardConfig", into: db.managedObjectContext) as! BoardConfig
        boardConfig.boardUpdateInterval = UpdateInterval.realTime.rawValue as NSNumber
        account.boardConfig = boardConfig
        
        let positionsConfig = NSEntityDescription.insertNewObject(forEntityName: "PositionsConfig", into: db.managedObjectContext) as! PositionsConfig
        positionsConfig.positionUpdateInterval = UpdateInterval.fiveSeconds.rawValue as NSNumber
        account.positionsConfig = positionsConfig
        
        let ordersConfig = NSEntityDescription.insertNewObject(forEntityName: "OrdersConfig", into: db.managedObjectContext) as! OrdersConfig
        ordersConfig.orderUpdateInterval = UpdateInterval.fiveSeconds.rawValue as NSNumber
        account.ordersConfig = ordersConfig
        
        Database.getDb().saveContext()
        
        return account
    }
    
    func delete(_ account: Account) {
        let db = Database.getDb()
        db.managedObjectContext.delete(account)
        db.saveContext()
    }
    
    fileprivate init() {
    }
    
    fileprivate static var inst: ConfigRepository? = nil
}
