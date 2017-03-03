//
//  Login.swift
//  zai
//
//  Created by Kyota Watanabe on 12/11/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift


func login(userId: String, password: String, callback: @escaping (_ err: ZaiError?, _ account: Account?) -> Void) {
    guard let account = AccountRepository.getInstance().findByUserIdAndPassword(userId, password: password) else {
        callback(ZaiError(errorType: .LOGIN_ERROR, message: Resource.invalidUserIdOrPassword), nil)
        return
    }
    
    account.activeExchange.validateApiKey() { err in
        
        // start monitoring chart
        let currencyPair = ApiCurrencyPair(rawValue: account.activeExchange.currencyPair)!
        let chartConfig = account.chartConfig
        let chartType = chartConfig.selectedCandleChartType
        var exchanges = [Exchange]()
        for exchange in account.exchanges {
            exchanges.append(exchange as! Exchange)
        }
        let charts = CandleChartContainer(exchanges: exchanges, currencyPair: currencyPair, interval: chartType, candleCount: 60)
        getApp().candleCharts = charts
        
        callback(err, account)
    }
    
    for ex in account.exchanges {
        let exchange = ex as! Exchange
        if exchange.name != account.activeExchangeName {
            exchange.validateApiKey() { _ in }
        }
    }
}

func loggout() {
    guard let account = getAccount() else {
        return
    }
    
    let app = getApp()
    
    // stop monitoring chart
    app.candleCharts.deactivateCharts()
    
    // stop monitoring trader assets
    account.activeExchange.trader.stopWatch()
    
    account.loggout()
    app.account = nil
    app.resource = createResource(exchangeName: "")
}


func isLogined() -> Bool {
    let app = UIApplication.shared.delegate as! AppDelegate
    return app.account != nil
}
