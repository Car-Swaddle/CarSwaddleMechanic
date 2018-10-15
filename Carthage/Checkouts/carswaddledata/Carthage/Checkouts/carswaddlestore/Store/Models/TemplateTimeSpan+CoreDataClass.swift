//
//  TemplateTimeSpan+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

public enum Weekday: Int16, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

@objc(TemplateTimeSpan)
public final class TemplateTimeSpan: NSManagedObject {
    
    @NSManaged public var primitiveWeekday: Int16
    private let weekdayKey = "weekday"
    
    public var weekday: Weekday {
        set {
            willChangeValue(forKey: weekdayKey)
            primitiveWeekday = newValue.rawValue
            didChangeValue(forKey: weekdayKey)
        }
        get {
            willAccessValue(forKey: weekdayKey)
            let value = Weekday(rawValue: primitiveWeekday)!
            didAccessValue(forKey: weekdayKey)
            return value
        }
    }

}
