//
//  AuthorityRequest+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension AuthorityRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorityRequest> {
        return NSFetchRequest<AuthorityRequest>(entityName: AuthorityRequest.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var requesterID: String
    @NSManaged public var expirationDate: Date
    @NSManaged public var authorityName: String
    @NSManaged public var creationDate: Date
    
    @NSManaged public var authorityConfirmationID: String?
    @NSManaged public var authorityID: String?
    @NSManaged public var secretID: String?
    
    @NSManaged public var requester: User?
    @NSManaged public var authority: Authority?
    @NSManaged public var authorityConfirmation: AuthorityConfirmation?

}
