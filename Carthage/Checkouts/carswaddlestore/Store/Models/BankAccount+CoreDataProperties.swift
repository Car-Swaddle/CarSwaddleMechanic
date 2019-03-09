//
//  BankAccount+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 3/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension BankAccount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BankAccount> {
        return NSFetchRequest<BankAccount>(entityName: BankAccount.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var accountID: String
    @NSManaged public var accountHolderName: String
    @NSManaged public var accountHolderType: String
    @NSManaged public var bankName: String
    @NSManaged public var country: String
    @NSManaged public var currency: String
    @NSManaged public var defaultForCurrency: Bool
    @NSManaged public var fingerprint: String
    @NSManaged public var last4: String
    @NSManaged public var routingNumber: String
    @NSManaged public var status: String
    @NSManaged public var mechanic: Mechanic?

}
