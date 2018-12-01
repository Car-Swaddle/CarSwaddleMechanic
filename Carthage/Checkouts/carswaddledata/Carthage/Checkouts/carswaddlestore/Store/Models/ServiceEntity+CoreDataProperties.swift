//
//  ServiceEntity+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 11/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension ServiceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServiceEntity> {
        return NSFetchRequest<ServiceEntity>(entityName: ServiceEntity.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var autoService: AutoService
    
    
    /// Optional relationships to only one service type.
    /// Only one of these should exist. It should be whatever the entityType is.
    @NSManaged public var oilChange: OilChange?

}
