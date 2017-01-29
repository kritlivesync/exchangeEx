//
//  Color.swift
//  zai
//
//  Created by Kyota Watanabe on 12/28/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

class Color {
    // base colors
    public static let keyColor = UIColor(red: 0.3, green: 0.69, blue: 0.31, alpha: 1.0) // rgba(76,175,80 ,1)
    public static let keyColor2 = UIColor(red: 0.26, green: 0.63, blue: 0.29, alpha: 1.0) // rgba(67,160,71 ,1)
    public static let antiKeyColor = UIColor.white
    public static let antiKeyColor2 = UIColor(red: 1.0, green: 0.56, blue: 0.0, alpha: 1.0)
    
    // navigation bar
    public static let naviBarColor = Color.keyColor
    
    // tab bar
    public static let tabBarColor = Color.keyColor
    public static let tabBarItemColor = Color.keyColor
    public static let tabBarUnselectedItemColor = UIColor.black

    // baord
    public static let askQuoteColor = UIColor(red: 0.12, green: 0.53, blue: 0.90, alpha: 1.0)
    public static let bidQuoteColor = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
    public static let makerButtonColor = Color.antiKeyColor2
    public static let takerButtonColor = Color.keyColor

    // positions
    public static let closedPositionColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
    public static let unwind100Color = antiKeyColor2 // rgba(255,143,0 ,1)
    public static let unwind50Color = UIColor(red: 0.62, green: 0.62, blue: 0.14, alpha: 1.0) // rgba(158,157,36 ,1)
    public static let unwind20Color = Color.keyColor
}
