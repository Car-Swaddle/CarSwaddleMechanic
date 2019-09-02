//
//  Vehicle+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/25/18.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: Vehicle.entityName)
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var user: User?
    @NSManaged public var autoServices: Set<AutoService>
    
    /// At least one of licensePlate or vin or vehicleDescription must not be nil.
    @NSManaged public var vin: String?
    @NSManaged public var licensePlate: String?
    @NSManaged public var state: String?
    @NSManaged public var vehicleDescription: VehicleDescription?

}
