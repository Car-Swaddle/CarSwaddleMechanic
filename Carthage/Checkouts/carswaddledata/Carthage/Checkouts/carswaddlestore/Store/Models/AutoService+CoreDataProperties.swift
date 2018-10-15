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
        autoService.creationDate = Date()
        autoService.identifier = tempID
        autoService.status = .created
        
        let oilChange = OilChange.createWithDefaults(context: context)
        oilChange.autoService = autoService
        
        return autoService
    }

    @NSManaged public var identifier: String
    @NSManaged public var notes: String?
    @NSManaged public var scheduledDate: Date?
    @NSManaged public var creationDate: Date
    @NSManaged public var creator: User
    @NSManaged public var mechanic: Mechanic?
    @NSManaged public var oilChange: OilChange?
    @NSManaged public var location: Location?
    @NSManaged public var price: Price?
    @NSManaged public var vehicle: Vehicle?

}
