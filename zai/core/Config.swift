//
//  Config.swift
//  zai
//
//  Created by 渡部郷太 on 8/22/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

enum UpdateInterval : Int {
    case realTime
    case oneSecond
    case fiveSeconds
    case tenSeconds
    case thirtySeconds
    case oneMinute
    
    var string: String {
        switch self {
        case .realTime: return "リアルタイム"
        case .oneSecond: return "1秒"
        case .fiveSeconds: return "5秒"
        case .tenSeconds: return "10秒"
        case .thirtySeconds: return "30秒"
        case .oneMinute: return "60秒"
        }
    }
    
    var int: Int {
        switch self {
        case .realTime: return 0
        case .oneSecond: return 1
        case .fiveSeconds: return 5
        case .tenSeconds: return 10
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        }
    }
    
    var double: Double {
        switch self {
        case .realTime: return 0.5
        case .oneSecond: return 1.0
        case .fiveSeconds: return 5.0
        case .tenSeconds: return 10.0
        case .thirtySeconds: return 30.0
        case .oneMinute: return 60.0
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

open class AppConfig : Config {
    
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
}


open class AssetsConfig : Config {
    
    override var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval_assets") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.fiveSeconds
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval_assets")
        }
    }
}

open class ChartConfig : Config {
    
    override var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval_chart") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.fiveSeconds
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval_chart")
        }
    }
}

open class BoardConfig : Config {
    
    override var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval_board") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.realTime
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval_board")
        }
    }
}

open class PositionsConfig : Config {
    
    override var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval_positions") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.fiveSeconds
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval_positions")
        }
    }
}

open class OrdersConfig : Config {
    
    override var autoUpdateInterval: UpdateInterval {
        get {
            if let val = Config.configDict.value(forKey: "autoUpdateInterval_orders") {
                return UpdateInterval(rawValue: (val as! Int))!
            }
            return UpdateInterval.fiveSeconds
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "autoUpdateInterval_orders")
        }
    }
}
