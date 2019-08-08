//
//  Service+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData


extension AutoService {
    
    public static let tempID = "AutoServiceTempID"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AutoService> {
        return NSFetchRequest<AutoService>(entityName: AutoService.entityName)
    }
    
    public static func createWithDefaults(context: NSManagedObjectContext) -> AutoService {
        let autoService = AutoService(context: context)
        
        let oilChange = OilChange(context: context)
        _ = ServiceEntity(autoService: autoService, oilChange: oilChange, context: context)
        autoService.vehicle = Vehicle.defaultVehicle(in: context)
        if let user = User.currentUser(context: context) {
            autoService.creator = user
        }
        
        return autoService
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var notes: String?
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var creationDate: Date
    @NSManaged public var creator: User?
    @NSManaged public var mechanic: Mechanic?
    @NSManaged public var location: Location?
    @NSManaged public var price: Price?
    @NSManaged public var vehicle: Vehicle?
    @NSManaged public var reviewFromUser: Review?
    @NSManaged public var reviewFromMechanic: Review?
    @NSManaged public var serviceEntities: Set<ServiceEntity>
    @NSManaged public var balanceTransactionID: String?
    @NSManaged public var chargeID: String?
    @NSManaged public var transferID: String?
    @NSManaged public var couponID: String?
    
    @NSManaged public var coupon: Coupon?

}
