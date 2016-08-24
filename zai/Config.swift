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
        if let val = Config.configDict.valueForKey("clearDBInInitialization") {
            return val as! Bool
        }
        return false
    }()
    
    static var previousUserId: String {
        if let val = Config.configDict.valueForKey("previousUserId") {
            return val as! String
        }
        return ""
    }
    
    static func setPreviousUserId(userId: String) {
        Config.configDict.setValue(userId, forKey: "previousUserId")
    }
    
    static var previousApiKey: String {
        if let val = Config.configDict.valueForKey("previousApiKey") {
            return val as! String
        }
        return ""
    }
    
    static func setPreviousApiKey(key: String) {
        Config.configDict.setValue(key, forKey: "previousApiKey")
    }
    
    static var previousSecretKey: String {
        if let val = Config.configDict.valueForKey("previousSecretKey") {
            return val as! String
        }
        return ""
    }
    
    static func setPreviousSecretKey(key: String) {
        Config.configDict.setValue(key, forKey: "previousSecretKey")
    }
    
    static func save() -> Bool {
        let d = Config.configDict
        let f = Config.configPath
        let b = Config.configDict.writeToFile(Config.configPath, atomically: true)
        return b
    }
    
    private static var configDict: NSMutableDictionary = {
        let path = Config.configPath
        var plist = NSMutableDictionary(contentsOfFile: path)
        if plist == nil {
            return Config.createDefaultConfigPlist(path)
        } else {
            return plist!
        }
    }()
    
    private static var configPath: String = {
        return NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!
    }()
    
    private static func createDefaultConfigPlist(path: String) -> NSMutableDictionary {
        let plist = NSMutableDictionary()
        plist.setValue(false, forKey: "clearDBInInitialization")
        plist.writeToFile(path, atomically: true)
        return plist
    }
}