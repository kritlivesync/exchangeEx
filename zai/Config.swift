//
//  Config.swift
//  zai
//
//  Created by 渡部郷太 on 8/22/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


public class Config {

    static var clearDBInInitialization: Bool = {
        if let dict = Config.configDict {
            if let val = dict.valueForKey("clearDBInInitialization") {
                return val as! Bool
            }
        }
        return false
    }()
    
    private static var configDict: NSDictionary? = {
        let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!
        return NSDictionary(contentsOfFile: path)
    }()
}