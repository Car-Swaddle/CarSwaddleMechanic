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

typealias VehicleValues = (identifier: String, name: String, licensePlate: String?, state: String?, vin: String?)

@objc(Vehicle)
public final class Vehicle: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Vehicle.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Vehicle.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values, json: json)
    }
    
    
    private static func values(from json: JSONObject) -> VehicleValues? {
        guard let identifier = json.identifier,
            let name = json["name"] as? String else { return nil }
        
        let licensePlate = json["licensePlate"] as? String
        let vin = json["vin"] as? String
        let state = json["state"] as? String
        
        if (licensePlate == nil && state == nil) && vin == nil {
            return nil
        }
        
        return (identifier, name, licensePlate, state, vin)
    }
    
    private func configure(with values: VehicleValues, json: JSONObject) {
        self.identifier = values.identifier
        self.creationDate = json["creationDate"] as? Date ?? Date()
        self.name = values.name
        self.licensePlate = values.licensePlate
        self.state = values.state
        self.vin = values.vin
        self.state = values.state
        
        if let userID = json["userID"] as? String,
            let context = managedObjectContext,
            let user = User.fetch(with: userID, in: context) {
            self.user = user
        }
    }
    
    public convenience init(name: String, licensePlate: String, state: String, user: User, context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = tempID
        self.creationDate = Date()
        self.name = name
        self.licensePlate = licensePlate
        self.user = user
        self.state = state
    }
    
    public var localizedDescription: String {
        if let state = state {
            let vehicleFormatString = NSLocalizedString("%@ • %@ • %@", comment: "Vehicle format string: 'vehicle name' • 'license plate number' • state of vehicle")
            return String(format: vehicleFormatString, name, licensePlate ?? "", state)
        } else {
            let vehicleFormatString = NSLocalizedString("%@ • %@", comment: "Vehicle format string: 'vehicle name' • 'license plate number'")
            return String(format: vehicleFormatString, name, licensePlate ?? "")
        }
    }
    
}


/// MARK: - Fetch

extension Vehicle {
    
    public static func fetchVehiclesForCurrentUser(in context: NSManagedObjectContext) -> [Vehicle] {
        guard let userID = User.currentUserID else { return [] }
        return Vehicle.fetchVehicles(forUserID: userID, in: context)
    }
    
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
