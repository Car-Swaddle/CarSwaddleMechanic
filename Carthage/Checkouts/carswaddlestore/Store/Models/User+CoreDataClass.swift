//
//  User+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/17/18.
//
//

import Foundation
import CoreData

private let currentUserIDKey = "currentUserIDKey"

@objc(User)
public final class User: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = User.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json)
    }
    
    
    public func configure(with json: JSONObject) throws {
        guard let values = User.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values, json: json)
    }
    
    
    private func configure(with identifier: String, json: JSONObject) {
        self.identifier = identifier
        self.firstName = json["firstName"] as? String
        self.lastName = json["lastName"] as? String
        self.phoneNumber = json["phoneNumber"] as? String
        
        guard let context = managedObjectContext else { return }
        
        if let mechanicJSON = json["mechanic"] as? JSONObject,
            let mechanic = Mechanic.fetchOrCreate(json: mechanicJSON, context: context) {
            self.mechanic = mechanic
        } else if let mechanicID = json["mechanicID"] as? String,
            let mechanic = Mechanic.fetch(with: mechanicID, in: context) {
            self.mechanic = mechanic
        }
    }
    
    private static func values(from json: JSONObject) -> String? {
        return json.identifier
    }
    
    public static func currentUser(context: NSManagedObjectContext) -> User? {
        guard let userID = currentUserID, let user = User.fetch(with: userID, in: context) else {
            return nil
        }
        return user
    }
    
    
    
    
    public static func setCurrentUserID(_ identifier: String) {
        UserDefaults.standard.set(identifier, forKey: currentUserIDKey)
    }
    
    public static var currentUserID: String? {
        return UserDefaults.standard.value(forKey: currentUserIDKey) as? String
    }
    
    public var displayName: String {
        var name: String = ""
        if let firstName = firstName {
            name += firstName
            name += " "
        }
        if let lastName = lastName {
            name += lastName
        }
        return name
    }
    
}



