//
//  Price+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData


extension Price {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: Price.entityName)
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var totalPrice: Int
    @NSManaged public var parts: Set<PricePart>
    @NSManaged public var autoService: AutoService?

}

// MARK: Generated accessors for parts
extension Price {

    @objc(addPartsObject:)
    @NSManaged public func addToParts(_ value: PricePart)

    @objc(removePartsObject:)
    @NSManaged public func removeFromParts(_ value: PricePart)

    @objc(addParts:)
    @NSManaged public func addToParts(_ values: NSSet)

    @objc(removeParts:)
    @NSManaged public func removeFromParts(_ values: NSSet)

}
