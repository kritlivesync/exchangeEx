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


enum UnwindingRule : Int {
    case mostBenefit
    case mostLoss
    case mostRecent
    case mostOld
    
    var string: String {
        switch self {
        case .mostBenefit: return "最も含み益の大きいポジション"
        case .mostLoss: return "最も含み損の大きいポジション"
        case .mostRecent: return "最も新しいポジション"
        case .mostOld: return "最も古いポジション"
        }
    }
    
    static var count: Int = {
        var i = 0
        while let _ = UnwindingRule(rawValue: i) {
            i += 1
        }
        return i
    }()
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
    
    var buyAmountLimitBtc: Double {
        get {
            if let val = Config.configDict.value(forKey: "buyAmountLimitBtc") {
                return val as! Double
            }
            return 0.0001
        }
        set {
            Config.configDict.setValue(newValue, forKey: "buyAmountLimitBtc")
        }
    }
    
    var unwindingRule: UnwindingRule {
        get {
            if let val = Config.configDict.value(forKey: "unwindingRule") {
                return UnwindingRule(rawValue: (val as! Int))!
            }
            return UnwindingRule.mostBenefit
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "unwindingRule")
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


enum ChandleChartType: Int {
    case oneMinute = 1
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    
    var string: String {
        switch self {
        case .oneMinute: return "1分足"
        case .fiveMinutes: return "5分足"
        case .fifteenMinutes: return "15分足"
        case .thirtyMinutes: return "30分足"
        }
    }
    
    var seconds: Int {
        switch self {
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        case .fifteenMinutes: return 900
        case .thirtyMinutes: return 1800
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
    
    var selectedCandleChart: ChandleChartType {
        get {
            if let val = Config.configDict.value(forKey: "selectedCandleChart") {
                return ChandleChartType(rawValue: (val as! Int))!
            }
            return ChandleChartType.oneMinute
        }
        set {
            Config.configDict.setValue(newValue.rawValue, forKey: "selectedCandleChart")
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
