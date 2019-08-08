//
//  Authority+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 6/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Authority {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Authority> {
        return NSFetchRequest<Authority>(entityName: Authority.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var name: String
    @NSManaged public var userID: String
    @NSManaged public var creationDate: Date
    
    @NSManaged public var authorityConfirmationID: String?
    @NSManaged public var authorityRequestID: String?
    
    @NSManaged public var user: User?
    @NSManaged public var authorityConfirmation: AuthorityConfirmation?
    @NSManaged public var authorityRequest: AuthorityRequest?

}


