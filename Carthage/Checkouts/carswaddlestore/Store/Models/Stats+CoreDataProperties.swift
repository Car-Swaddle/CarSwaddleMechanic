//
//  Stats+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: Stats.entityName)
    }

    @NSManaged public var averageRating: Double
    @NSManaged public var numberOfRatings: Int
    @NSManaged public var autoServicesProvided: Int
    @NSManaged public var mechanic: Mechanic?

}
