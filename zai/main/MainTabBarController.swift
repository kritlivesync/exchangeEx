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
        
        let trader = TraderRepository.getInstance().findTraderByName(Config.currentTraderName, api: self.account.privateApi)
        
        let assets = self.viewControllers![0] as! AssetsViewController
        assets.account = self.account
        assets.trader = trader
        
        let board = self.viewControllers![1] as! BoardViewController
        board.account = self.account
        board.trader = trader
        
        let positions = self.viewControllers![2] as! PositionsViewController
        positions.account = self.account
        positions.trader = trader
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    internal var account: Account!
}
