//
//  TemplateTimeSpan+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

typealias TemplateTimeSpanValues = (identifier: String, duration: TimeInterval, weekday: Weekday, date: Date, mechanicID: String)

public enum Weekday: Int16, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    public var localizedString: String {
        switch self {
        case .sunday: return NSLocalizedString("Sunday", comment: "Day of the week")
        case .monday: return NSLocalizedString("Monday", comment: "Day of the week")
        case .tuesday: return NSLocalizedString("Tuesday", comment: "Day of the week")
        case .wednesday: return NSLocalizedString("Wednesday", comment: "Day of the week")
        case .thursday: return NSLocalizedString("Thursday", comment: "Day of the week")
        case .friday: return NSLocalizedString("Friday", comment: "Day of the week")
        case .saturday: return NSLocalizedString("Saturday", comment: "Day of the week")
        }
    }
    
}

@objc(TemplateTimeSpan)
public final class TemplateTimeSpan: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = TemplateTimeSpan.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = TemplateTimeSpan.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values, json: json)
    }
    
    
    private func configure(with values: TemplateTimeSpanValues, json: JSONObject) {
        self.identifier = values.identifier
        self.duration = values.duration
        self.startTime = Int64(values.date.secondsSinceMidnight())
        self.weekday = values.weekday
        if let context = managedObjectContext,
            let mechanic = Mechanic.fetch(with: values.mechanicID, in: context) {
            self.mechanic = mechanic
        }
    }
    
    private static func values(from json: JSONObject) -> TemplateTimeSpanValues? {
        guard let identifier = json["id"] as? String,
            let duration = json["duration"] as? Double,
            let weekdayInt = json["weekDay"] as? Int16,
            let weekday = Weekday(rawValue: weekdayInt),
            let dateString = json["startTime"] as? String,
            let date = TemplateTimeSpan.dateFormatter.date(from: dateString),
            let mechanicID = json["mechanicID"] as? String else { return nil }
        return (identifier, duration, weekday, date, mechanicID)
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
    
    public static func fetch(with weekday: Weekday, mechanicID: String, in context: NSManagedObjectContext) -> [TemplateTimeSpan] {
        let fetchRequest: NSFetchRequest<TemplateTimeSpan> = TemplateTimeSpan.fetchRequest()
        
        let mechanicPredicate = TemplateTimeSpan.predicate(forMechanicID: mechanicID)
        let weekdayPredicate = TemplateTimeSpan.predicate(for: weekday)
        let predicates: [NSPredicate] = [mechanicPredicate, weekdayPredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    public static func predicate(forMechanicID mechanicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(TemplateTimeSpan.mechanic.identifier), mechanicID)
    }
    
    public static func predicate(for weekday: Weekday) -> NSPredicate {
        return NSPredicate(format: "weekday == %i", weekday.rawValue)
    }

}


