//
//  Account+CoreDataProperties.swift
//  
//
//  Created by Kyota Watanabe on 1/29/17.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account");
    }

    @NSManaged public var activeExchangeName: String
    @NSManaged public var lastBackgroundDate: NSNumber
    @NSManaged public var lastLoginDate: NSNumber
    @NSManaged public var password: String
    @NSManaged public var salt: String
    @NSManaged public var userId: String
    @NSManaged public var appConfig: AppConfig
    @NSManaged public var assetsConfig: AssetsConfig
    @NSManaged public var boardConfig: BoardConfig
    @NSManaged public var chartConfig: ChartConfig
    @NSManaged public var exchanges: NSSet
    @NSManaged public var ordersConfig: OrdersConfig
    @NSManaged public var positionsConfig: PositionsConfig

}

// MARK: Generated accessors for exchanges
extension Account {

    @objc(addExchangesObject:)
    @NSManaged public func addToExchanges(_ value: Exchange)

    @objc(removeExchangesObject:)
    @NSManaged public func removeFromExchanges(_ value: Exchange)

    @objc(addExchanges:)
    @NSManaged public func addToExchanges(_ values: NSSet)

    @objc(removeExchanges:)
    @NSManaged public func removeFromExchanges(_ values: NSSet)

}
