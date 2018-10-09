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
        case created
        case requested
        case canceled
        case inProgress
        case completed
    }
    
    public enum AutoServiceType: String {
        case oilChange
    }
    
}

private let statusKey = "status"
private let typeKey = "type"

@objc(AutoService)
public final class AutoService: NSManagedObject, NSManagedObjectFetchable {
    
    @NSManaged private var primitiveStatus: String
    @NSManaged private var primitiveType: String
    
    public var status: Status {
        set {
            willChangeValue(forKey: statusKey)
            primitiveStatus = newValue.rawValue
            didChangeValue(forKey: statusKey)
        }
        get {
            willAccessValue(forKey: statusKey)
            let enumValue = Status(rawValue: primitiveStatus) ?? .created
            didAccessValue(forKey: statusKey)
            return enumValue
        }
    }
    
    
    public var type: AutoServiceType {
        set {
            willChangeValue(forKey: typeKey)
            primitiveType = newValue.rawValue
            didChangeValue(forKey: typeKey)
        }
        get {
            willAccessValue(forKey: typeKey)
            let enumValue = AutoServiceType(rawValue: primitiveType) ?? .oilChange
            didAccessValue(forKey: typeKey)
            return enumValue
        }
    }
    
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
    
}
