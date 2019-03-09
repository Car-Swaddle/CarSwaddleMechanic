//
//  Address+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 12/25/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: Address.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var line1: String?
    @NSManaged public var line2: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var country: String?
    
    @NSManaged public var mechanic: Mechanic?

}
