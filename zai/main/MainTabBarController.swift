//
//  MainTabViewController.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true

        UITabBar.appearance().tintColor = Color.tabBarItemColor
        
        let chartNavi = self.viewControllers![1] as! UINavigationController
        let chartController = chartNavi.viewControllers[0] as! ChartViewController
        let account = getAccount()!
        chartController.candleChart = CandleChart(currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: account.activeExchange.api)
        chartController.candleChart.delegate = chartController
        
        // start monitoring active orders to be promised
        _ = getAccount()?.activeExchange.trader.activeOrders
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
