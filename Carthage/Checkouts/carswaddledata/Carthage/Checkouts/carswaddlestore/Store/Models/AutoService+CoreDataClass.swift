//
//  Service+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData


public extension AutoService {
    
    enum Status: String {
        case scheduled
        case canceled
        case inProgress
        case completed
        
        public var localizedString: String {
            switch self {
            case .canceled: return NSLocalizedString("canceled", comment: "auto service status")
            case .inProgress: return NSLocalizedString("in progress", comment: "auto service status")
            case .completed: return NSLocalizedString("completed", comment: "auto service status")
            case .scheduled: return NSLocalizedString("scheduled", comment: "auto service status")
            }
        }
        
    }
    
}

private let statusKey = "status"
private let typeKey = "type"
private let isCanceledKey = "isCanceled"

let serverDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

typealias AutoServiceValues = (identifier: String, scheduledDate: Date, status: AutoService.Status, userID: String, mechanicID: String, balanceTransactionID: String?, transferID: String?, chargeID: String?, couponID: String?)

@objc(AutoService)
public final class AutoService: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = AutoService.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = AutoService.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values, json: json)
    }
    
    private static func values(from json: JSONObject) -> AutoServiceValues? {
        guard let id = json.identifier,
            let scheduledDateString = json["scheduledDate"] as? String,
            let scheduledDate = serverDateFormatter.date(from: scheduledDateString),
            let statusString = json["status"] as? String,
            let status = AutoService.Status(rawValue: statusString),
            let userID = json["userID"] as? String,
            let mechanicID = json["mechanicID"] as? String else { return nil }
        let couponID = json["couponID"] as? String
        let balanceTransactionID = json["balanceTransactionID"] as? String
        let transferID = json["transferID"] as? String
        let chargeID = json["chargeID"] as? String
        return (id, scheduledDate, status, userID, mechanicID, balanceTransactionID, transferID, chargeID, couponID)
    }
    
    private func configure(with values: AutoServiceValues, json: JSONObject) {
        self.identifier = values.identifier
        self.scheduledDate = values.scheduledDate
        self.status = values.status
        self.notes = json["notes"] as? String
        self.balanceTransactionID = values.balanceTransactionID
        self.couponID = values.couponID
        self.transferID = values.transferID
        self.chargeID = values.chargeID
        
        guard let context = managedObjectContext else { return }
        
        if let vehicleJSON = json["vehicle"] as? JSONObject {
            self.vehicle = Vehicle.fetchOrCreate(json: vehicleJSON, context: context)
        }
        
        if let locationJSON = json["location"] as? JSONObject {
            self.location = Location.fetchOrCreate(json: locationJSON, context: context)
        }
        
        var serviceEntities: Set<ServiceEntity> = []
        for entityJSON in json["serviceEntities"] as? [JSONObject] ?? [] {
            guard let serviceEntity = ServiceEntity.fetchOrCreate(json: entityJSON, context: context) else { continue }
            serviceEntities.insert(serviceEntity)
        }
        
        if let mechanicJSON = json["mechanic"] as? JSONObject,
            let mechanic = Mechanic.fetchOrCreate(json: mechanicJSON, context: context) {
            self.mechanic = mechanic
        } else if let mechanic = Mechanic.fetch(with: values.mechanicID, in: context) {
            self.mechanic = mechanic
        }
        
        if let userJSON = json["user"] as? JSONObject,
            let user = User.fetchOrCreate(json: userJSON, context: context) {
            self.creator = user
        } else if let user = User.fetch(with: values.userID, in: context) {
            creator = user
        }
        
        if let reviewFromUserJSON = json["reviewFromUser"] as? JSONObject {
            self.reviewFromUser = Review.fetchOrCreate(json: reviewFromUserJSON, context: context)
        }
        
        if let reviewFromMechanic = json["reviewFromMechanic"] as? JSONObject {
            self.reviewFromMechanic = Review.fetchOrCreate(json: reviewFromMechanic, context: context)
        }
    }
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        primitiveCreationDate = Date()
        primitiveIdentifier = AutoService.tempID
        primitiveStatus = Status.scheduled.rawValue
    }
    
    @NSManaged private var primitiveIdentifier: String
    @NSManaged private var primitiveCreationDate: Date
    @NSManaged private var primitiveStatus: String
    
    @NSManaged private var primitiveIsCanceled: NSNumber
    
    public var status: Status {
        set {
            willChangeValue(forKey: statusKey)
            primitiveStatus = newValue.rawValue
            didChangeValue(forKey: statusKey)
            
            willChangeValue(forKey: isCanceledKey)
            primitiveIsCanceled = NSNumber(value: newValue == .canceled)
            didChangeValue(forKey: isCanceledKey)
        }
        get {
            willAccessValue(forKey: statusKey)
            let enumValue = Status(rawValue: primitiveStatus) ?? .scheduled
            didAccessValue(forKey: statusKey)
            return enumValue
        }
    }
    
    /// Bool value for data base usage. Reflects value found in `status`.
    @objc public var isCanceled: Bool {
        willAccessValue(forKey: isCanceledKey)
        let value = primitiveIsCanceled.boolValue
        didAccessValue(forKey: isCanceledKey)
        return value
    }
    
}

struct StoreError: Error {
    let rawValue: String
    
    static let invalidJSON = StoreError(rawValue: "invalidJSON")
    static let noPathToPersistentStore = StoreError(rawValue: "noPathToPersistentStore")
}

extension AutoService {
    
    public var canConvertToJSON: Bool {
        return (try? toJSON()) != nil
    }
    
    public static func fetchMostRecentlyUsed(forUserID userID: String, in context: NSManagedObjectContext) -> AutoService? {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest(forUserID: userID)
        fetchRequest.sortDescriptors = [recentlyUsedSort]
        fetchRequest.fetchLimit = 1
        return ((try? context.fetch(fetchRequest)) ?? []).first
    }
    
    public static func fetchRequest(forUserID userID: String) -> NSFetchRequest<AutoService> {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest()
        fetchRequest.predicate = AutoService.predicate(forUserID: userID)
        return fetchRequest
    }
    
    public static func predicate(forUserID userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(AutoService.creator.identifier), userID)
    }
    
    public static var recentlyUsedSort: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.creationDate), ascending: true)
    }
    
    public func toJSON(includeIdentifiers: Bool = false) throws -> JSONObject {
        var json: JSONObject = [:]
        
        if let locationID = location?.identifier {
            json["locationID"] = locationID
        } else if let location = location {
            json["location"] = location.toJSON()
        } else {
            throw StoreError.invalidJSON
        }
        
        if let mechanic = mechanic {
            json["mechanicID"] = mechanic.identifier
        } else {
            throw StoreError.invalidJSON
        }
        
        if let scheduledDate = scheduledDate {
            json["scheduledDate"] = serverDateFormatter.string(from: scheduledDate)
        } else {
            throw StoreError.invalidJSON
        }
        
        let jsonArray = serviceEntities.toJSONArray(includeIdentifiers: includeIdentifiers, includeEntityIdentifiers: false)
        if jsonArray.count > 0 {
            json["serviceEntities"] = jsonArray
        } else {
            throw StoreError.invalidJSON
        }
        
        if let vehicleID = vehicle?.identifier {
            json["vehicleID"] = vehicleID
        } else {
            throw StoreError.invalidJSON
        }
        
        json["status"] = status.rawValue
        json["notes"] = notes
        json["couponID"] = couponID
        
        return json
    }
    
    public var firstOilChange: OilChange? {
        return serviceEntities.first(where: { entity -> Bool in
            return entity.entityType == .oilChange
        })?.oilChange
    }
    
    
    
}


public extension AutoService {
    
    // MARK: - Predicates
    
    static func predicate(startDate: Date, endDate: Date) -> NSPredicate {
        return NSPredicate(format: "%@ <= %K && %K <= %@", startDate as NSDate, #keyPath(AutoService.scheduledDate), #keyPath(AutoService.scheduledDate), endDate as NSDate)
    }
    
    // MARK: - Scheduled Date Sort
    
    static var leastRecentRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: false)
    }
    
    static var mostRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: true)
    }
    
    static func scheduledDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.scheduledDate), ascending: ascending)
    }
    
    // MARK: - Creation Date Sort
    
    static var leastRecentRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: false)
    }
    
    static var mostRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: true)
    }
    
    static func creationDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.creationDate), ascending: ascending)
    }
    
    // MARK: -
    
    static var isCanceledSort: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.isCanceled), ascending: true)
    }
    
}

