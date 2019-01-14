//
//  Balance+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


public extension Balance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Balance> {
        return NSFetchRequest<Balance>(entityName: Balance.entityName)
    }

    @NSManaged public var available: Amount
    @NSManaged public var pending: Amount
    @NSManaged public var reserved: Amount?
    @NSManaged public var mechanic: Mechanic?

}
