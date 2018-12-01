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

    @NSManaged public var identifier: String
    /// The second of the day
    @NSManaged public var startTime: Int64
    /// The number of seconds
    @NSManaged public var duration: TimeInterval
    @NSManaged public var mechanic: Mechanic

}
