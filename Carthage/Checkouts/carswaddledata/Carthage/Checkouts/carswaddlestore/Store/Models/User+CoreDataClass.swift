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
        guard let id = json["id"] as? String else {
                return nil
        }
        self.init(context: context)
        self.identifier = id
        self.firstName = json["firstName"] as? String
        self.lastName = json["lastName"] as? String
        self.phoneNumber = json["phoneNumber"] as? String
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



