//
//  PricePart+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData


extension PricePart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PricePart> {
        return NSFetchRequest<PricePart>(entityName: PricePart.entityName)
    }

    @NSManaged public var key: String
    @NSManaged public var value: Int
    @NSManaged public var price: Price

}
