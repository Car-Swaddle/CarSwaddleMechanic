//
//  Vehicle+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

private let tempID = "vehicleTempID"

@objc(Vehicle)
public final class Vehicle: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let identifier = json.identifier,
            let name = json["name"] as? String else { return nil }
        
        let licensePlate = json["licensePlate"] as? String
        let vin = json["vin"] as? String
        
        if licensePlate == nil && vin == nil {
            return nil
        }
        
        self.init(context: context)
        
        self.identifier = identifier
        self.creationDate = json["creationDate"] as? Date ?? Date()
        self.name = name
        self.licensePlate = licensePlate
        self.vin = vin
        if let userID = json["userID"] as? String,
            let user = User.fetch(with: userID, in: context) {
            self.user = user
        }
    }
    
    public convenience init(name: String, licensePlate: String, user: User, context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = tempID
        self.creationDate = Date()
        self.name = name
        self.licensePlate = licensePlate
        self.user = user
    }
    
}


/// MARK: - Fetch

extension Vehicle {
    
//    public static func fetchMostRecentlyUsedVehicle(forUserID userID: String, in context: NSManagedObjectContext) -> Vehicle? {
//        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest(forUserID: userID)
//        fetchRequest.sortDescriptors = [recentlyUsedSort]
//        fetchRequest.fetchLimit = 1
//        return ((try? context.fetch(fetchRequest)) ?? []).first
//    }
    
    public static func defaultVehicle(in context: NSManagedObjectContext) -> Vehicle? {
        guard let userID = User.currentUserID else { return nil }
        let recentlyUsedAutoService = AutoService.fetchMostRecentlyUsed(forUserID: userID, in: context)?.vehicle
        return  recentlyUsedAutoService ?? Vehicle.fetchFirstVehicle(forUserID: userID, in: context)
    }
    
    public static func fetchVehicles(forUserID userID: String, in context: NSManagedObjectContext) -> [Vehicle] {
        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequestRecentlyCreated(forUserID: userID)
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    public static func fetchFirstVehicle(forUserID userID: String, in context: NSManagedObjectContext) -> Vehicle? {
        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequestRecentlyCreated(forUserID: userID)
        fetchRequest.fetchLimit = 1
        return ((try? context.fetch(fetchRequest)) ?? []).first
    }
    
    public static func fetchRequestRecentlyCreated(forUserID userID: String) -> NSFetchRequest<Vehicle> {
        let fetchRequest: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        fetchRequest.predicate = Vehicle.predicate(forUserID: userID)
        fetchRequest.sortDescriptors = [creationDateSort]
        return fetchRequest
    }
    
    public static func predicate(forUserID userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Vehicle.user.identifier), userID)
    }
    
    
    // MARK: - Sort Descriptors
    
    public static var creationDateSort: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Vehicle.creationDate), ascending: true)
    }
    
}
