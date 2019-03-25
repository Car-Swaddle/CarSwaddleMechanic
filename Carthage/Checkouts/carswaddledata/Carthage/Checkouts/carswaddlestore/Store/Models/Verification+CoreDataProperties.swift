//
//  Verification+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Verification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Verification> {
        return NSFetchRequest<Verification>(entityName: Verification.entityName)
    }

    @NSManaged public var disabledReason: String?
    @NSManaged public var dueByDate: Date?
    @NSManaged public var mechanic: Mechanic?
    
    @NSManaged public var pastDue: Set<VerificationField>
    @NSManaged public var currentlyDue: Set<VerificationField>
    @NSManaged public var eventuallyDue: Set<VerificationField>

    public var typedFieldsPastDue: [VerificationField.Field] {
        return pastDue.compactMap { $0.typedValue }
    }
    
    public var typedFieldsCurrentlyDue: [VerificationField.Field] {
        return currentlyDue.compactMap { $0.typedValue }
    }
    
    public var typedFieldsEventuallyDue: [VerificationField.Field] {
        return eventuallyDue.compactMap { $0.typedValue }
    }
    
    public var typedDisabledReason: DisabledReason? {
        guard let typedDisabledReason = DisabledReason(rawValue: disabledReason ?? "") else {
            print("Unable to type: \(disabledReason ?? ""), to DisabledReason")
            return nil
        }
        return typedDisabledReason
    }
    
    public enum DisabledReason: String {
        case rejectedFraud = "rejected.fraud"
        case rejectedTermsOfService = "rejected.terms_of_service"
        case rejectedListed = "rejected.listed"
        case rejectedOther = "rejected.other"
        case fieldsNeeded = "fields_needed"
        case listed
        case underReview = "under_review"
        case other
    }

}

// MARK: Generated accessors for fields
extension Verification {

    @objc(addFieldsObject:)
    @NSManaged public func addToFields(_ value: VerificationField)

    @objc(removeFieldsObject:)
    @NSManaged public func removeFromFields(_ value: VerificationField)

    @objc(addFields:)
    @NSManaged public func addToFields(_ values: NSSet)

    @objc(removeFields:)
    @NSManaged public func removeFromFields(_ values: NSSet)

}
