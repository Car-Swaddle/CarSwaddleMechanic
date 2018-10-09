//
//  VehicleDescription+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/25/18.
//
//

import Foundation
import CoreData


extension VehicleDescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VehicleDescription> {
        return NSFetchRequest<VehicleDescription>(entityName: VehicleDescription.entityName)
    }

    @NSManaged public var make: String
    @NSManaged public var model: String
    @NSManaged public var year: String
    @NSManaged public var trim: String
    @NSManaged public var style: String?
    @NSManaged public var vehicle: Vehicle

}
