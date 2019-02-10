//
//  TransactionReceipt+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 2/3/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension TransactionReceipt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionReceipt> {
        return NSFetchRequest<TransactionReceipt>(entityName: TransactionReceipt.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var receiptPhotoID: String
    @NSManaged public var transactionMetadata: TransactionMetadata?
    @NSManaged public var createdAt: Date

}
