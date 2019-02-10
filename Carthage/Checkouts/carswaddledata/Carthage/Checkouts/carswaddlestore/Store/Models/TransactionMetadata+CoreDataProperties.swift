//
//  TransactionMetadata+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 2/3/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension TransactionMetadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionMetadata> {
        return NSFetchRequest<TransactionMetadata>(entityName: TransactionMetadata.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var stripeTransactionID: String
    @NSManaged public var mechanicCost: Int
    @NSManaged public var drivingDistance: Int
    @NSManaged public var autoServiceID: String
    @NSManaged public var mechanicID: String
    @NSManaged public var createdAt: Date
    @NSManaged public var transaction: Transaction?
    @NSManaged public var autoService: AutoService?
    @NSManaged public var receipts: Set<TransactionReceipt>

}

// MARK: Generated accessors for receipts
extension TransactionMetadata {

    @objc(addReceiptsObject:)
    @NSManaged public func addToReceipts(_ value: TransactionReceipt)

    @objc(removeReceiptsObject:)
    @NSManaged public func removeFromReceipts(_ value: TransactionReceipt)

    @objc(addReceipts:)
    @NSManaged public func addToReceipts(_ values: NSSet)

    @objc(removeReceipts:)
    @NSManaged public func removeFromReceipts(_ values: NSSet)

}
