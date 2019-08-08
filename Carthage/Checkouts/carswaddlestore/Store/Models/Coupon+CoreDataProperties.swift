//
//  Coupon+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Coupon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coupon> {
        return NSFetchRequest<Coupon>(entityName: Coupon.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var creationDate: Date
    @NSManaged public var createdByUserID: String
    @NSManaged public var createdByMechanicID: String?
    @NSManaged public var discountBookingFee: Bool
    @NSManaged public var isCorporate: Bool
    @NSManaged public var name: String
    @NSManaged public var redeemBy: Date
    @NSManaged public var redemptions: Int
    @NSManaged public var updatedAt: Date
    @NSManaged public var user: User?
    @NSManaged public var autoservices: Set<AutoService>

}


/*
 identifier
 
 */
