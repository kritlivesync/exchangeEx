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
        
        let assetsNavi = self.viewControllers![0] as! UINavigationController
        assetsNavi.navigationBar.barTintColor = Color.naviBarColor
        
        let boardNavi = self.viewControllers![1] as! UINavigationController
        boardNavi.navigationBar.barTintColor = Color.naviBarColor
        
        let positionsNavi = self.viewControllers![2] as! UINavigationController
        positionsNavi.navigationBar.barTintColor = Color.naviBarColor
        
        let ordersNavi = self.viewControllers![3] as! UINavigationController
        ordersNavi.navigationBar.barTintColor = Color.naviBarColor
        
        // start monitoring active orders to be promised
        _ = getAccount()?.activeExchange.trader.activeOrders
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
