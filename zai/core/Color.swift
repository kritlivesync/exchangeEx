//
//  Color.swift
//  zai
//
//  Created by 渡部郷太 on 12/28/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

class Color {
    // base colors
    public static let keyColor = UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0)
    public static let antiKeyColor = UIColor(red: 1.0, green: 0.56, blue: 0.0, alpha: 1.0)
    
    // navigation bar
    public static let naviBarColor = Color.keyColor
    
    // tab bar
    public static let tabBarColor = Color.keyColor
    public static let tabBarItemColor = Color.antiKeyColor
    public static let tabBarUnselectedItemColor = UIColor.black

    // baord
    public static let askQuoteColor = UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.0)
    public static let bidQuoteColor = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
    public static let makerButtonColor = Color.antiKeyColor
    public static let takerButtonColor = Color .keyColor

    // positions
    public static let closedPositionColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
}
