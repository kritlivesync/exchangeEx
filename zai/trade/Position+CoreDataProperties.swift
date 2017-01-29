//
//  Position+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 12/23/16.
//
//

import Foundation
import CoreData


extension Position {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position");
    }

    @NSManaged public var id: String
    @NSManaged public var status: NSNumber
    @NSManaged public var tradeLogs: NSOrderedSet
    @NSManaged public var trader: Trader?
    @NSManaged public var activeOrder: Order?

}

// MARK: Generated accessors for tradeLogs
extension Position {

    @objc(insertObject:inTradeLogsAtIndex:)
    @NSManaged public func insertIntoTradeLogs(_ value: TradeLog, at idx: Int)

    @objc(removeObjectFromTradeLogsAtIndex:)
    @NSManaged public func removeFromTradeLogs(at idx: Int)

    @objc(insertTradeLogs:atIndexes:)
    @NSManaged public func insertIntoTradeLogs(_ values: [TradeLog], at indexes: NSIndexSet)

    @objc(removeTradeLogsAtIndexes:)
    @NSManaged public func removeFromTradeLogs(at indexes: NSIndexSet)

    @objc(replaceObjectInTradeLogsAtIndex:withObject:)
    @NSManaged public func replaceTradeLogs(at idx: Int, with value: TradeLog)

    @objc(replaceTradeLogsAtIndexes:withTradeLogs:)
    @NSManaged public func replaceTradeLogs(at indexes: NSIndexSet, with values: [TradeLog])

    @objc(addTradeLogsObject:)
    @NSManaged public func addToTradeLogs(_ value: TradeLog)

    @objc(removeTradeLogsObject:)
    @NSManaged public func removeFromTradeLogs(_ value: TradeLog)

    @objc(addTradeLogs:)
    @NSManaged public func addToTradeLogs(_ values: NSOrderedSet)

    @objc(removeTradeLogs:)
    @NSManaged public func removeFromTradeLogs(_ values: NSOrderedSet)

}
