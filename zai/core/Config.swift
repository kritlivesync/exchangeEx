//
//  Config.swift
//  zai
//
//  Created by Kyota Watanabe on 8/22/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation




open class Config {
    
    var autoUpdateInterval: UpdateInterval {
        get {
            return UpdateInterval.fiveSeconds
        }
        set {
            return
        }
    }
    
    func save() -> Bool {
        return Config.configDict.write(toFile: Config.configPath, atomically: true)
    }
    
    fileprivate static var configDict: NSMutableDictionary = {
        let path = Config.configPath
        guard let plist = NSMutableDictionary(contentsOfFile: path) else {
            return Config.createDefaultConfigPlist(path)
        }
        return plist
    }()
    
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




open class GlobalConfig : Config {
    
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
    
    var language: Language {
        get {
            if let val = Config.configDict.value(forKey: "language") {
                return Language(rawValue: val as! Int)!
            }
            return Language.japanese
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "language")
        }
    }
    
}
