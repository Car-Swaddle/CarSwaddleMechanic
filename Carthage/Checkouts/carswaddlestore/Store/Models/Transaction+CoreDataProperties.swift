//
//  Transaction+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: Transaction.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var amount: Int
//    @NSManaged public var availableOn: Date
    @NSManaged public var created: Date
    @NSManaged public var currency: String
    @NSManaged public var transactionDescription: String?
    @NSManaged public var exchangeRate: NSNumber?
    @NSManaged public var fee: Int
    @NSManaged public var net: Int
    @NSManaged public var source: String
    @NSManaged public var type: String
    @NSManaged public var mechanic: Mechanic?
    @NSManaged public var payout: Payout?
    @NSManaged public var transactionMetadata: TransactionMetadata?
    
    @NSManaged public var adjustedAvailableOnDate: Date

}
