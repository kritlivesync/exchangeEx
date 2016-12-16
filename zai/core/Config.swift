//
//  Config.swift
//  zai
//
//  Created by 渡部郷太 on 8/22/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


open class Config {
    
    var currentTraderName: String {
        get {
            if let val = Config.configDict.value(forKey: "currentTraderName") {
                return val as! String
            }
            return ""
        }
        set {
            Config.configDict.setValue(newValue, forKey: "currentTraderName")
        }
    }
    
    var previousUserId: String {
        get {
            if let val = Config.configDict.value(forKey: "previousUserId") {
                return val as! String
            }
            return ""
        }
        set {
            Config.configDict.setValue(newValue, forKey: "previousUserId")
        }
    }

    var previousApiKey: String {
        get {
            if let val = Config.configDict.value(forKey: "previousApiKey") {
                return val as! String
            }
            return ""
        }
        set {
            Config.configDict.setValue(newValue, forKey: "previousApiKey")
        }
    }
    
    var previousSecretKey: String {
        get {
            if let val = Config.configDict.value(forKey: "previousSecretKey") {
                return val as! String
            }
            return ""
        }
        set {
            Config.configDict.setValue(newValue, forKey: "previousSecretKey")
        }
    }
    
    var sellMaxProfitPosition: Bool {
        get {
            if let val = Config.configDict.value(forKey: "sellMaxProfitPosition") {
                return val as! Bool
            }
            return true
        }
        set {
            Config.configDict.setValue(newValue, forKey: "sellMaxProfitPosition")
        }
    }
    
    func save() -> Bool {
        return Config.configDict.write(toFile: Config.configPath, atomically: true)
    }
    
    fileprivate static var configDict: NSMutableDictionary = {
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
    
    fileprivate static var preInstallPath: String {
        return Bundle.main.path(forResource: "Config", ofType: "plist")!
    }
    
    fileprivate static var configPath: String {
        let docs = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").path
        return docs + "/zai.plist"
    }
    
    fileprivate static func createDefaultConfigPlist(_ path: String) -> NSMutableDictionary {
        let plist = NSMutableDictionary()
        plist.setValue(false, forKey: "clearDBInInitialization")
        plist.write(toFile: path, atomically: true)
        return plist
    }
}
