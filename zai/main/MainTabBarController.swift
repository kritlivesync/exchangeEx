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

        //UITabBar.appearance().barTintColor = Color.tabBarColor
        UITabBar.appearance().tintColor = Color.tabBarItemColor
        //UITabBar.appearance().unselectedItemTintColor = Color.tabBarUnselectedItemColor
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        let trader = TraderRepository.getInstance().findTraderByName(app.config.currentTraderName, api: self.account.privateApi)
        
        let assetsNavi = self.viewControllers![0] as! UINavigationController
        assetsNavi.navigationBar.barTintColor = Color.naviBarColor
        let assets = assetsNavi.viewControllers[0] as! AssetsViewController
        assets.account = self.account
        assets.trader = trader
        
        let boardNavi = self.viewControllers![1] as! UINavigationController
        boardNavi.navigationBar.barTintColor = Color.naviBarColor
        let board = boardNavi.viewControllers[0] as! BoardViewController
        board.account = self.account
        board.trader = trader
        
        let positionsNavi = self.viewControllers![2] as! UINavigationController
        positionsNavi.navigationBar.barTintColor = Color.naviBarColor
        let positions = positionsNavi.viewControllers[0] as! PositionsViewController
        positions.account = self.account
        positions.trader = trader
        
        let ordersNavi = self.viewControllers![3] as! UINavigationController
        ordersNavi.navigationBar.barTintColor = Color.naviBarColor
        let orders = ordersNavi.viewControllers[0] as! OrdersViewController
        orders.account = self.account
        orders.trader = trader
        
        // start monitoring active orders to be promised
        _ = trader?.activeOrders
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    internal var account: Account!
}
