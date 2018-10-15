//
//  TemplateTimeSpan+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData


extension TemplateTimeSpan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateTimeSpan> {
        return NSFetchRequest<TemplateTimeSpan>(entityName: TemplateTimeSpan.entityName)
    }

    /// The minute of the day 
    @NSManaged public var startTime: Int64
    @NSManaged public var duration: Double
    @NSManaged public var mechanic: Mechanic

}
