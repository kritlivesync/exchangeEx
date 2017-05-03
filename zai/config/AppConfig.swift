//
//  AppConfig+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


enum UpdateInterval : Int {
    case realTime
    case oneSecond
    case twoSeconds
    case threeSeconds
    case fourSeconds
    case fiveSeconds
    case tenSeconds
    case thirtySeconds
    case oneMinute
    
    var string: String {
        switch self {
        case .realTime: return "リアルタイム"
        case .oneSecond: return "1秒"
        case .twoSeconds: return "2秒"
        case .threeSeconds: return "3秒"
        case .fourSeconds: return "4秒"
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
        case .twoSeconds: return 2
        case .threeSeconds: return 3
        case .fourSeconds: return 4
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
        case .twoSeconds: return 2.0
        case .threeSeconds: return 3.0
        case .fourSeconds: return 4.0
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


enum Language : Int {
    case japanese
    case english
}


public class AppConfig: NSManagedObject {
    
    var buyAmountLimitBtcValue: Double {
        get {
            return self.buyAmountLimitBtc.doubleValue
        }
        set {
            self.buyAmountLimitBtc = NSNumber(value: newValue)
            Database.getDb().saveContext()
        }
    }

    var footerUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.footerUpdateInterval.intValue)!
        }
        set {
            self.footerUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
    var unwindingRuleType: UnwindingRule {
        get {
            return UnwindingRule(rawValue: self.unwindingRule.intValue)!
        }
        set {
            self.unwindingRule = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
    var languageType: Language {
        get {
            return Language(rawValue: self.language.intValue)!
        }
        set {
            self.language = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
}
