//
//  Region+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: Region.entityName)
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var radius: Double
    @NSManaged public var mechanic: Mechanic?

}
