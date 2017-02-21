//
//  MainTabViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 12/11/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true

        UITabBar.appearance().tintColor = Color.tabBarItemColor
        
        self.tabBar.items![0].image = self.tabBar.items![0].image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![0].selectedImage = self.tabBar.items![0].selectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![1].image = self.tabBar.items![1
            ].image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![1].selectedImage = self.tabBar.items![1
            ].selectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![2].image = self.tabBar.items![2].image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![2].selectedImage = self.tabBar.items![2].selectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![3].image = self.tabBar.items![3].image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![3].selectedImage = self.tabBar.items![3].selectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![4].image = self.tabBar.items![4].image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.tabBar.items![4].selectedImage = self.tabBar.items![4].selectedImage?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let chartNavi = self.viewControllers![1] as! UINavigationController
        let chartController = chartNavi.viewControllers[0] as! ChartViewController
        let account = getAccount()!
        
        let currencyPair = ApiCurrencyPair(rawValue: account.activeExchange.currencyPair)!
        let chartConfig = getChartConfig()
        let chartType = chartConfig.selectedCandleChartType
        chartController.candleChart = CandleChart(currencyPair: currencyPair, interval: chartType, candleCount: 60, api: account.activeExchange.api)
        chartController.candleChart.monitoringInterval = chartConfig.chartUpdateIntervalType
        chartController.candleChart.delegate = chartController
        
        let trader = account.activeExchange.trader
        trader.fixPositionsWithInvalidOrder()
        for position in trader.allPositions {
            position.delegate = (UIApplication.shared.delegate as! AppDelegate).notification
        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
