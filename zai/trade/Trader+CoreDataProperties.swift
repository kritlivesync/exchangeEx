//
//  Trader+CoreDataProperties.swift
//  
//
//  Created by 渡部郷太 on 1/3/17.
//
//

import Foundation
import CoreData


extension Trader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trader> {
        return NSFetchRequest<Trader>(entityName: "Trader");
    }

    @NSManaged public var name: String
    @NSManaged public var status: String
    @NSManaged public var exchange: Exchange
    @NSManaged public var positions: NSOrderedSet

}

// MARK: Generated accessors for positions
extension Trader {

    @objc(insertObject:inPositionsAtIndex:)
    @NSManaged public func insertIntoPositions(_ value: Position, at idx: Int)

    @objc(removeObjectFromPositionsAtIndex:)
    @NSManaged public func removeFromPositions(at idx: Int)

    @objc(insertPositions:atIndexes:)
    @NSManaged public func insertIntoPositions(_ values: [Position], at indexes: NSIndexSet)

    @objc(removePositionsAtIndexes:)
    @NSManaged public func removeFromPositions(at indexes: NSIndexSet)

    @objc(replaceObjectInPositionsAtIndex:withObject:)
    @NSManaged public func replacePositions(at idx: Int, with value: Position)

    @objc(replacePositionsAtIndexes:withPositions:)
    @NSManaged public func replacePositions(at indexes: NSIndexSet, with values: [Position])

    @objc(addPositionsObject:)
    @NSManaged public func addToPositions(_ value: Position)

    @objc(removePositionsObject:)
    @NSManaged public func removeFromPositions(_ value: Position)

    @objc(addPositions:)
    @NSManaged public func addToPositions(_ values: NSOrderedSet)

    @objc(removePositions:)
    @NSManaged public func removeFromPositions(_ values: NSOrderedSet)

}
