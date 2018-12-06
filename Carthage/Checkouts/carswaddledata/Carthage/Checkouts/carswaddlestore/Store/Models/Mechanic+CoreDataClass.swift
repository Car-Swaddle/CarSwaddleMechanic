//
//  Mechanic+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData

@objc(Mechanic)
public final class Mechanic: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let identifier = json.identifier else { return nil }
        
        self.init(context: context)
        self.identifier = identifier
        self.isActive = json["isActive"] as? Bool ?? false
        
        if let userJSON = json["user"] as? JSONObject,
            let user = User.fetchOrCreate(json: userJSON, context: context) {
            self.user = user
        } else if let userID = json["userID"] as? String,
            let user = User.fetch(with: userID, in: context) {
            self.user = user
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
