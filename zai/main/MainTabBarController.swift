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
        
        let account = getAccount()!
        let trader = account.activeExchange.trader
        trader.fixPositionsWithInvalidOrder()
        for position in trader.allPositions {
            position.delegate = (UIApplication.shared.delegate as! AppDelegate).notification
        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
