//
//  Amount+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


public extension Amount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Amount> {
        return NSFetchRequest<Amount>(entityName: Amount.entityName)
    }

    @NSManaged public var value: Int
    @NSManaged public var currency: String
    @NSManaged public var balanceForAvailable: Balance?
    @NSManaged public var balanceForPending: Balance?
    @NSManaged public var balanceForReserved: Balance?

}
