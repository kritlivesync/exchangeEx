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
        
        let vc = self.viewControllers?[0] as! MainViewController
        vc.account = self.account
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let vc = viewController as! MainViewController
        vc.account = self.account
        
    }
    
    internal var account: Account!
}
