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
        
        let assets = self.viewControllers?[0] as! AssetsViewController
        assets.account = self.account
        
        let board = self.viewControllers?[1] as! BoardViewController
        board.account = self.account
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
    internal var account: Account!
}
