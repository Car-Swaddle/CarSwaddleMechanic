//
//  User+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/17/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: User.entityName)
    }
    
    @NSManaged public var identifier: String
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var averageRating: CGFloat
    
    @NSManaged public var services: Set<AutoService>
    @NSManaged public var vehicles: Set<Vehicle>
    @NSManaged public var reviews: Set<Review>
    @NSManaged public var mechanic: Mechanic?
    @NSManaged public var profileImageID: String?
    @NSManaged public var email: String?
    @NSManaged public var isPhoneNumberVerified: Bool
    @NSManaged public var isEmailVerified: Bool
    @NSManaged public var pushDeviceToken: String?
    @NSManaged public var timeZone: String?
    
    @NSManaged public var authorities: Set<Authority>
    @NSManaged public var authorityRequests: Set<AuthorityRequest>
    @NSManaged public var authorityConfirmations: Set<AuthorityConfirmation>
    @NSManaged public var coupons: Set<Coupon>
    
}

// MARK: Generated accessors for requestServices
extension User {

    @objc(addServicesObject:)
    @NSManaged public func addToRequestServices(_ value: AutoService)

    @objc(removeServicesObject:)
    @NSManaged public func removeFromRequestServices(_ value: AutoService)

    @objc(addServices:)
    @NSManaged public func addToRequestServices(_ values: NSSet)

    @objc(removeServices:)
    @NSManaged public func removeFromRequestServices(_ values: NSSet)

}

// MARK: Generated accessors for vehicles
extension User {

    @objc(addVehiclesObject:)
    @NSManaged public func addToVehicles(_ value: Vehicle)

    @objc(removeVehiclesObject:)
    @NSManaged public func removeFromVehicles(_ value: Vehicle)

    @objc(addVehicles:)
    @NSManaged public func addToVehicles(_ values: NSSet)

    @objc(removeVehicles:)
    @NSManaged public func removeFromVehicles(_ values: NSSet)

}
