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
    @NSManaged public var autoService: AutoService?
    
    @NSManaged public var oilChangeCost: Int
    @NSManaged public var distanceCost: Int
    @NSManaged public var bookingFee: Int
    @NSManaged public var processingFee: Int
    @NSManaged public var subtotal: Int
    @NSManaged public var taxes: Int
    @NSManaged public var total: Int

}
