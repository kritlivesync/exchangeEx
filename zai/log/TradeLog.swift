//
//  TradeLog.swift
//  
//
//  Created by 渡部郷太 on 8/23/16.
//
//

import Foundation
import CoreData


public enum TradeAction : String {
    case ORDER = "ORDER"
    case CANCEL = "CANCEL"
    case OPEN_LONG_POSITION = "OPEN_LONG_POSITION"
    case OPEN_SHORT_POSITION = "OPEN_SHORT_POSITION"
    case CLOSE_LONG_POSITION = "CLOSE_LONG_POSITION"
    case CLOSE_SHORT_POSITION = "CLOSE_SHORT_POSITION"
    case UNWIND_LONG_POSITION = "UNWIND_LONG_POSITION"
    case UNWIND_SHORT_POSITION = "UNWIND_SHORT_POSITION"
}


public class TradeLog: NSManagedObject {

}
