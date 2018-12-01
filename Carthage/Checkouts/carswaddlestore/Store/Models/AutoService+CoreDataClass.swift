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
    
    public enum Status: String {
        case scheduled
        case canceled
        case inProgress
        case completed
    }
    
}

private let statusKey = "status"
private let typeKey = "type"

private let serverDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

@objc(AutoService)
public final class AutoService: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let id = json.identifier,
            let scheduledDateString = json["scheduledDate"] as? String,
            let scheduledDate = serverDateFormatter.date(from: scheduledDateString),
            let statusString = json["status"] as? String,
            let status = AutoService.Status(rawValue: statusString),
            let userID = json["userID"] as? String,
            let mechanicID = json["mechanicID"] as? String else { return nil }
        
        self.init(context: context)
        self.identifier = id
        self.scheduledDate = scheduledDate
        self.status = status
        self.notes = json["notes"] as? String
        
        if let vehicleJSON = json["vehicle"] as? JSONObject {
            self.vehicle = Vehicle.fetchOrCreate(json: vehicleJSON, context: context)
        }
        
        if let locationJSON = json["location"] as? JSONObject {
            self.location = Location.fetchOrCreate(json: locationJSON, context: context)
        }
        
        var serviceEntities: Set<ServiceEntity> = []
        for entityJSON in json["serviceEntities"] as? [JSONObject] ?? [] {
            guard let serviceEntity = ServiceEntity(json: entityJSON, context: context) else { continue }
            serviceEntities.insert(serviceEntity)
        }
        
        mechanic = Mechanic.fetch(with: mechanicID, in: context)
        if let user = User.fetch(with: userID, in: context) {
            creator = user
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
    
    public var status: Status {
        set {
            willChangeValue(forKey: statusKey)
            primitiveStatus = newValue.rawValue
            didChangeValue(forKey: statusKey)
        }
        get {
            willAccessValue(forKey: statusKey)
            let enumValue = Status(rawValue: primitiveStatus) ?? .scheduled
            didAccessValue(forKey: statusKey)
            return enumValue
        }
    }
    
}

struct StoreError: Error {
    let rawValue: String
    
    static let invalidJSON = StoreError(rawValue: "invalidJSON")
}

extension AutoService {
    
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
        
        return json
    }
    
    public var firstOilChange: OilChange? {
        return serviceEntities.first(where: { entity -> Bool in
            return entity.entityType == .oilChange
        })?.oilChange
    }
    
}
