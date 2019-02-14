//
//  TaxInfo+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension TaxInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaxInfo> {
        return NSFetchRequest<TaxInfo>(entityName: TaxInfo.entityName)
    }

    @NSManaged public var year: String
    @NSManaged public var metersDriven: Int
    @NSManaged public var mechanicCostInCents: Int
    @NSManaged public var mechanic: Mechanic

}
