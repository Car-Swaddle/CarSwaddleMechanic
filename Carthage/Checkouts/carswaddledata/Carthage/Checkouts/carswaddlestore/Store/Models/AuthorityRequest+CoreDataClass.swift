//
//  AuthorityRequest+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias AuthorityRequestValues = (identifier: String, requesterID: String, expirationDate: Date, authorityName: String, creationDate: Date, secretID: String?, authorityConfirmationID: String?, authorityID: String?, authorityConfirmationJSON: [String: Any]?, userJSON: [String: Any])


@objc(AuthorityRequest)
final public class AuthorityRequest: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    convenience public init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = AuthorityRequest.values(from: json, in: context) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let context = managedObjectContext,
            let values = AuthorityRequest.values(from: json, in: context) else { throw StoreError.invalidJSON }
        configure(with: values)
    }
    
    private func configure(with values: AuthorityRequestValues) {
        self.identifier = values.identifier
        self.requesterID = values.requesterID
        self.expirationDate = values.expirationDate
        self.creationDate = values.creationDate
        self.authorityName = values.authorityName
        self.authorityConfirmationID = values.authorityConfirmationID
        self.authorityID = values.authorityID
        self.secretID = values.secretID
        
        guard let context = managedObjectContext else { return }
        
        if let user = User.fetch(with: self.requesterID, in: context) {
            self.requester = user
        }
        if let user = User.fetchOrCreate(json: values.userJSON, context: context) {
            self.requester = user
        }
        if let authorityID = self.authorityID, let authority = Authority.fetch(with: authorityID, in: context) {
            self.authority = authority
        }
        if let authorityConfirmationID = self.authorityConfirmationID, let authorityConfirmation = AuthorityConfirmation.fetch(with: authorityConfirmationID, in: context) {
            self.authorityConfirmation = authorityConfirmation
        }
        
        if let authorityConfirmationJSON = values.authorityConfirmationJSON {
            self.authorityConfirmation = AuthorityConfirmation.fetchOrCreate(json: authorityConfirmationJSON, context: context)
        }
    }
    
    private static func values(from json: JSONObject, in context: NSManagedObjectContext) -> AuthorityRequestValues? {
        guard let identifier = json["id"] as? String,
            let authorityName = json["authorityName"] as? String,
            let expirationDateString = json["expirationDate"] as? String,
            let createdAtString = json["createdAt"] as? String,
            let expirationDate = serverDateFormatter.date(from: expirationDateString),
            let creationDate = serverDateFormatter.date(from: createdAtString),
            let userJSON = json["user"] as? JSONObject,
            let requesterID = userJSON["id"] as? String else { return nil }
        
        let authorityConfirmationJSON = json["authorityConfirmation"] as? JSONObject
        let authorityConfirmationID = authorityConfirmationJSON?["id"] as? String
        
        let authorityID = json["authorityID"] as? String
        let secretID = json["secretID"] as? String
        
        return (identifier, requesterID, expirationDate, authorityName, creationDate, secretID, authorityConfirmationID, authorityID, authorityConfirmationJSON, userJSON)
    }
    
}



/*
 
 "id": "5f0e8710-8cce-11e9-9276-b34dfcd5b928",
 "authorityName": "Noathatkjghasdf",
 "expirationDate": "2019-06-13T04:55:59.745Z",
 "createdAt": "2019-06-12T04:55:59.746Z",
 "updatedAt": "2019-06-12T04:55:59.746Z",
 "authorityID": null,
 "requesterID": "007a7440-8cc2-11e9-94d5-9bf65e4a0328",
 "user": {
     "firstName": null,
     "lastName": null,
     "id": "007a7440-8cc2-11e9-94d5-9bf65e4a0328",
     "profileImageID": null,
     "email": "kyle@carswaddle.com",
     "phoneNumber": null,
     "timeZone": "America/Denver"
 }
 
 */
