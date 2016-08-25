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
        return Config.configDict.writeToFile(Config.configPath, atomically: true)
    }
    
    private static var configDict: NSMutableDictionary = {
        let path = Config.configPath
        var plist = NSMutableDictionary(contentsOfFile: path)
        if plist == nil {
            let prePath = Config.preInstallPath
            plist = NSMutableDictionary(contentsOfFile: prePath)
            if plist == nil {
                plist = Config.createDefaultConfigPlist(path)
            }
        }
        return plist!
    }()
    
    private static var preInstallPath: String = {
        return NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!
    }()
    
    private static var configPath: String = {
        let docs = NSURL(fileURLWithPath: NSHomeDirectory()).URLByAppendingPathComponent("Documents").path!
        return docs.stringByAppendingString("/zai.plist")
    }()
    
    private static func createDefaultConfigPlist(path: String) -> NSMutableDictionary {
        let plist = NSMutableDictionary()
        plist.setValue(false, forKey: "clearDBInInitialization")
        plist.writeToFile(path, atomically: true)
        return plist
    }
}