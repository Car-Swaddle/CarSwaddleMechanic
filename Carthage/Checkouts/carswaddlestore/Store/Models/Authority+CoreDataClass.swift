//
//  Authority+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias AuthorityValues = (identifier: String, userID: String, authorityName: String, creationDate: Date, confirmationJSON: JSONObject, userJSON: JSONObject)

@objc(Authority)
final public class Authority: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    convenience public init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Authority.values(from: json, in: context) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let context = managedObjectContext,
            let values = Authority.values(from: json, in: context) else { throw StoreError.invalidJSON }
        configure(with: values)
    }
    
    private func configure(with values: AuthorityValues) {
        self.identifier = values.identifier
        self.name = values.authorityName
        self.creationDate = values.creationDate
        self.userID = values.userID
        self.authorityConfirmationID = values.confirmationJSON["id"] as? String
        
        guard let context = managedObjectContext else { return }
        
        self.authorityConfirmation = AuthorityConfirmation.fetchOrCreate(json: values.confirmationJSON, context: context)
        
        self.user = User.fetchOrCreate(json: values.userJSON, context: context)
    }
    
    private static func values(from json: JSONObject, in context: NSManagedObjectContext) -> AuthorityValues? {
        guard let identifier = json["id"] as? String,
            let authorityName = json["authorityName"] as? String,
            let creationDateString = json["createdAt"] as? String,
            let creationDate = serverDateFormatter.date(from: creationDateString),
            let userID = json["userID"] as? String,
            let authorityConfirmationJSON = json["authorityConfirmation"] as? JSONObject,
            let userJSON = json["user"] as? JSONObject else { return nil }
        
        return (identifier, userID, authorityName, creationDate, authorityConfirmationJSON, userJSON)
    }
    
}

extension Authority {
    
    public static func currentUserHas(authority: String, in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Authority.currentUserAuthoritiesPredicate(), Authority.currentUserHasAuthority(withName: authority)])
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        
        return ((try? context.count(for: fetchRequest)) ?? 0) != 0
    }
    
    public static func currentUser(has authority: Authority.Name, in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Authority.currentUserAuthoritiesPredicate(), Authority.currentUser(has: authority)])
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        
        return ((try? context.count(for: fetchRequest)) ?? 0) != 0
    }
    
    public static func fetchCurrentUserAuthorities(in context: NSManagedObjectContext) -> [Authority] {
        let fetchRequest: NSFetchRequest<Authority> = Authority.fetchRequest()
        fetchRequest.predicate = Authority.currentUserAuthoritiesPredicate()
        fetchRequest.sortDescriptors = [Authority.creationDateSortDescriptor]
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    public static func currentUserHasAuthority(withName name: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Authority.name), name)
    }
    
    public static func currentUser(has authority: Authority.Name) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Authority.name), authority.rawValue)
    }
    
    public static func currentUserAuthoritiesPredicate() -> NSPredicate {
        guard let currentUserID = User.currentUserID else {
            return NSPredicate(value: false)
        }
        return Authority.authoritiesPredicate(forUserID: currentUserID)
    }
    
    public static func authoritiesPredicate(forUserID userID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Authority.userID), userID)
    }
    
    public static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Authority.creationDate), ascending: true)
    }
    
}


extension Authority {
    
    public struct Name: Equatable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
    }
    
}

/*
 {
 "id": "5c37d130-8e5f-11e9-8136-ffee546f26bb",
 "authorityName": "editAuthorities",
 "createdAt": "2019-06-14T04:46:23.176Z",
 "updatedAt": "2019-06-14T04:46:23.176Z",
 "userID": "19a48340-8e5f-11e9-8136-ffee546f26bb",
 "authorityConfirmation": {
     "id": "5c364a90-8e5f-11e9-8136-ffee546f26bb",
     "status": "approved",
     "createdAt": "2019-06-14T04:46:23.161Z",
     "updatedAt": "2019-06-14T04:46:23.189Z",
     "authorityID": "5c37d130-8e5f-11e9-8136-ffee546f26bb",
     "confirmerID": "19a48340-8e5f-11e9-8136-ffee546f26bb",
     "authorityRequestID": "27d09850-8e5f-11e9-8136-ffee546f26bb",
     "user": {
         "firstName": null,
         "lastName": null,
         "id": "19a48340-8e5f-11e9-8136-ffee546f26bb",
         "profileImageID": null,
         "email": "kyle@carswaddle.com",
         "phoneNumber": null,
         "timeZone": "America/Denver"
     }
 },
 "user": {
     "firstName": null,
     "lastName": null,
     "id": "19a48340-8e5f-11e9-8136-ffee546f26bb",
     "profileImageID": null,
     "email": "kyle@carswaddle.com",
     "phoneNumber": null,
     "timeZone": "America/Denver"
  }
 }
 */
