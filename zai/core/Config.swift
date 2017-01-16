//
//  Config.swift
//  zai
//
//  Created by 渡部郷太 on 8/22/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

enum UpdateInterval : Int {
    case oneSecond
    case fiveSeconds
    case tenSeconds
    case thirtySeconds
    case oneMinute
    case realTime
    
    var string: String {
        switch self {
        case .oneSecond: return "1秒"
        case .fiveSeconds: return "5秒"
        case .tenSeconds: return "10秒"
        case .thirtySeconds: return "30秒"
        case .oneMinute: return "60秒"
        case .realTime: return "リアルタイム"
        }
    }
    
    var int: Int {
        switch self {
        case .oneSecond: return 1
        case .fiveSeconds: return 5
        case .tenSeconds: return 10
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        case .realTime: return 0
        }
    }
    
    var double: Double {
        switch self {
        case .oneSecond: return 1.0
        case .fiveSeconds: return 5.0
        case .tenSeconds: return 10.0
        case .thirtySeconds: return 30.0
        case .oneMinute: return 60.0
        case .realTime: return 0.5
        }
    }
    
    static var count: Int = {
        var i = 0
        while let _ = UpdateInterval(rawValue: i) {
            i += 1
        }
        return i
    }()
}


open class Config {
    
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
    
    var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.fiveSeconds
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval")
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
