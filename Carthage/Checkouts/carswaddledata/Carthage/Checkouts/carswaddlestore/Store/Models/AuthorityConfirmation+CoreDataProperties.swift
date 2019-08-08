//
//  AuthorityConfirmation+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension AuthorityConfirmation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorityConfirmation> {
        return NSFetchRequest<AuthorityConfirmation>(entityName: AuthorityConfirmation.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var authorityRequestID: String
    @NSManaged public var confirmerID: String // userID of user who confirmed authorityRequest
    @NSManaged public var creationDate: Date
    
    @NSManaged public var authorityID: String?
    
    @NSManaged public var authority: Authority?
    @NSManaged public var authorityRequest: AuthorityRequest?
    
    /// user who confirmed authorityRequest
    @NSManaged public var confirmer: User?

}


