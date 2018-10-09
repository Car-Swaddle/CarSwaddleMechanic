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
public final class User: NSManagedObject, NSManagedObjectFetchable {
    
    public static func currentUser(context: NSManagedObjectContext) -> User? {
        guard let userID = currentUserID,
            let user = User.fetch(with: userID, in: context) else {
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
    
}



