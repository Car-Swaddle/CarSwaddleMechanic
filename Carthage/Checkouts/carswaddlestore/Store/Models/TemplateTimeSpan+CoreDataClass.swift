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
public final class TemplateTimeSpan: NSManagedObject, NSManagedObjectFetchable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let identifier = json["id"] as? String,
            let duration = json["duration"] as? Double,
            let weekdayInt = json["weekDay"] as? Int16,
            let mechanicID = json["mechanicID"] as? String,
            let mechanic = Mechanic.fetch(with: mechanicID, in: context),
            let weekday = Weekday(rawValue: weekdayInt),
            let dateString = json["startTime"] as? String,
            let date = TemplateTimeSpan.dateFormatter.date(from: dateString) else { return nil }
        
        self.init(context: context)
        self.identifier = identifier
        self.duration = duration
        self.startTime = Int64(date.secondsSinceMidnight())
        self.weekday = weekday
        self.mechanic = mechanic
    }
    
    
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
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    public var toJSON: JSONObject {
        return ["startTime": startTime, "duration": duration, "weekDay": weekday.rawValue]
    }
    
    public var startTimeStringFormat: String {
        return startTime.timeOfDayFormattedString
    }

}


