//
//  OilChangePricing+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 8/21/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension OilChangePricing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OilChangePricing> {
        return NSFetchRequest<OilChangePricing>(entityName: OilChangePricing.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var conventional: Int64
    @NSManaged public var blend: Int64
    @NSManaged public var synthetic: Int64
    @NSManaged public var highMileage: Int64
    @NSManaged public var centsPerMile: Int64
    @NSManaged public var mechanicID: String
    @NSManaged public var mechanic: Mechanic?

}
