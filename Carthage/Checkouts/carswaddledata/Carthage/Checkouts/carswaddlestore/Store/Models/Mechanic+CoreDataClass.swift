//
//  Mechanic+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

//typealias MechanicValues = identifier: String

@objc(Mechanic)
public final class Mechanic: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Mechanic.values(from: json) else { return nil }
        self.init(context: context)
        configure(from: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Mechanic.values(from: json) else { throw StoreError.invalidJSON }
        configure(from: values, json: json)
    }
    
    private static func values(from json: JSONObject) -> String? {
        return json.identifier
    }
    
    private func configure(from identifier: String, json: JSONObject)  {
        self.identifier = identifier
        self.isActive = json["isActive"] as? Bool ?? false
        
        if let dateOfBirthString = json["dateOfBirth"] as? String {
            self.dateOfBirth = serverDateFormatter.date(from: dateOfBirthString)
        }
        
        guard let context = managedObjectContext else { return }
        
        if let userJSON = json["user"] as? JSONObject,
            let user = User.fetchOrCreate(json: userJSON, context: context) {
            self.user = user
        } else if let userID = json["userID"] as? String,
            let user = User.fetch(with: userID, in: context) {
            self.user = user
        }
        
        if let addressJSON = json["address"] as? JSONObject {
            let address = Address.fetchOrCreate(json: addressJSON, context: context)
            self.address = address
        }
    }
    

    public static func currentLoggedInMechanic(in context: NSManagedObjectContext) -> Mechanic? {
        return User.currentUser(context: context)?.mechanic
    }
    
    public func deleteAllCurrentScheduleTimeSpans() {
        for timespan in scheduleTimeSpans {
            managedObjectContext?.delete(timespan)
        }
    }
    
}
