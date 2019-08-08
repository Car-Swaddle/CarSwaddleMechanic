//
//  AuthorityConfirmation+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias AuthorityConfirmationValues = (identifier: String, status: String, creationDate: Date, authorityID: String?, confirmerID: String, authorityRequestID: String, confirmerJSON: JSONObject)

@objc(AuthorityConfirmation)
final public class AuthorityConfirmation: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    convenience public init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = AuthorityConfirmation.values(from: json, in: context) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let context = managedObjectContext,
            let values = AuthorityConfirmation.values(from: json, in: context) else { throw StoreError.invalidJSON }
        configure(with: values)
    }
    
    private func configure(with values: AuthorityConfirmationValues) {
        self.identifier = values.identifier
        self.status = Status(rawValue: values.status) ?? .rejected
        self.creationDate = values.creationDate
        self.authorityID = values.authorityID
        self.confirmerID = values.confirmerID
        self.authorityRequestID = values.authorityRequestID
        
        guard let context = managedObjectContext else { return }
        
        if let authorityID = self.authorityID {
            self.authority = Authority.fetch(with: authorityID, in: context)
        }
        self.confirmer = User.fetchOrCreate(json: values.confirmerJSON, context: context)
        self.authorityRequest = AuthorityRequest.fetch(with: authorityRequestID, in: context)
    }
    
    private static func values(from json: JSONObject, in context: NSManagedObjectContext) -> AuthorityConfirmationValues? {
        guard let identifier = json["id"] as? String,
            let status = json["status"] as? String,
            let creationDateString = json["createdAt"] as? String,
            let creationDate = serverDateFormatter.date(from: creationDateString),
            let confirmerID = json["confirmerID"] as? String,
            let authorityRequestID = json["authorityRequestID"] as? String,
            let userJSON = json["user"] as? JSONObject else { return nil }
        
        let authorityID = json["authorityID"] as? String
        
        return (identifier, status, creationDate, authorityID, confirmerID, authorityRequestID, userJSON)
    }
    
    
    public enum Status: String {
        case rejected
        case approved
    }
    
    
    private let statusKey = "status"
    
    @NSManaged private var primitiveStatus: String

    public var status: Status {
        set {
            willChangeValue(forKey: statusKey)
            primitiveStatus = newValue.rawValue
            didChangeValue(forKey: statusKey)
        }
        get {
            willAccessValue(forKey: statusKey)
            guard let status = Status(rawValue: primitiveStatus) else {
                fatalError("Must have value for status, unable to parse or empty value. Got: \(primitiveStatus)")
            }
            didAccessValue(forKey: statusKey)
            
            return status
        }
    }
    
}

/*
 "id": "ab3efe00-8ccc-11e9-88fa-75b1f398e259",
 "userID": "007a7440-8cc2-11e9-94d5-9bf65e4a0328",
 "authorityName": "readAuthorities",
 "createdAt": "2019-06-12T04:43:48.584Z",
 "updatedAt": "2019-06-12T04:43:48.584Z",
 "authorityConfirmation": {
     "id": "ab3cdb20-8ccc-11e9-88fa-75b1f398e259",
     "status": "approved",
     "createdAt": "2019-06-12T04:43:48.563Z",
     "updatedAt": "2019-06-12T04:43:48.600Z",
     "authorityID": "ab3efe00-8ccc-11e9-88fa-75b1f398e259",
     "confirmerID": "007a7440-8cc2-11e9-94d5-9bf65e4a0328",
     "authorityRequestID": "94636630-8ccc-11e9-a813-f383bd49ea0f",
     "user": {
         "firstName": null,
         "lastName": null,
         "id": "007a7440-8cc2-11e9-94d5-9bf65e4a0328",
         "profileImageID": null,
         "email": "kyle@carswaddle.com",
         "phoneNumber": null,
         "timeZone": "America/Denver"
     }
 }
 
 
 
 @NSManaged public var identifier: String
 @NSManaged public var status: String
 @NSManaged public var creationDate: Date
 @NSManaged public var authorityID: String?
 @NSManaged public var confirmerID: String
 @NSManaged public var authorityRequestID: String
 
 @NSManaged public var authority: Authority?
 @NSManaged public var authorityRequest: AuthorityRequest?
 @NSManaged public var confirmer: User?// user who confirmed authorityRequest
 
 */



