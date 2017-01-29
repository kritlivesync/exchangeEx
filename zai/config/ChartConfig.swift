//
//  ChartConfig+CoreDataClass.swift
//  
//
//  Created by Kyota Watanabe on 1/28/17.
//
//

import Foundation
import CoreData


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


public class ChartConfig: NSManagedObject {

    var chartUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.chartUpdateInterval.intValue)!
        }
        set {
            self.chartUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
    var quoteUpdateIntervalType: UpdateInterval {
        get {
            return UpdateInterval(rawValue: self.quoteUpdateInterval.intValue)!
        }
        set {
            self.quoteUpdateInterval = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
    
    var selectedCandleChartType: ChandleChartType {
        get {
            return ChandleChartType(rawValue: self.selectedCandleChart.intValue)!
        }
        set {
            self.selectedCandleChart = newValue.rawValue as NSNumber
            Database.getDb().saveContext()
        }
    }
}
