//
//  Review+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: Review.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var rating: CGFloat
    @NSManaged public var text: String?
    @NSManaged public var reviewerID: String
    @NSManaged public var revieweeID: String
    @NSManaged public var user: User?
    @NSManaged public var mechanic: Mechanic?
    @NSManaged public var autoServiceFromMechanic: AutoService?
    @NSManaged public var autoServiceFromUser: AutoService?
    @NSManaged public var creationDate: Date
    
    public var autoService: AutoService? {
        return autoServiceFromMechanic ?? autoServiceFromUser
    }

}
