//
//  LaunchViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 12/31/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


class LaunchViewController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = Color.keyColor
        self.navigationBar.tintColor = Color.antiKeyColor
    }
}
