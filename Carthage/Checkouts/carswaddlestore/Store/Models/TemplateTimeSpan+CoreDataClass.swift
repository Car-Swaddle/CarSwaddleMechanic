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
    
    private let weekdayKey = "weekday"
    
    public var weekday: Weekday {
        set {
            willChangeValue(forKey: weekdayKey)
            setPrimitiveValue(newValue.rawValue, forKey: weekdayKey)
            didChangeValue(forKey: weekdayKey)
        }
        get {
            willAccessValue(forKey: weekdayKey)
            let primitiveWeekday = primitiveValue(forKey: weekdayKey) as! Int16
            let value = Weekday(rawValue: primitiveWeekday)!
            didAccessValue(forKey: weekdayKey)
            return value
        }
    }

}
