//
//  Mechanic+CoreDataProperties.swift
//  
//
//  Created by Kyle Kendall on 9/30/18.
//
//

import Foundation
import CoreData


extension Mechanic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mechanic> {
        return NSFetchRequest<Mechanic>(entityName: Mechanic.entityName)
    }

    @NSManaged public var identifier: String
    @NSManaged public var isActive: Bool
    @NSManaged public var isAllowed: Bool
    @NSManaged public var user: User?
    @NSManaged public var scheduleTimeSpans: Set<TemplateTimeSpan>
    @NSManaged public var services: Set<AutoService>
    @NSManaged public var reviews: Set<Review>
    @NSManaged public var serviceRegion: Region?
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var address: Address?
    @NSManaged public var stats: Stats?
    @NSManaged public var profileImageID: String?
    @NSManaged public var pushDeviceToken: String?
    @NSManaged public var balance: Balance?
    @NSManaged public var transactions: Set<Transaction>
    @NSManaged public var payouts: Set<Payout>
    @NSManaged public var identityDocumentID: String?
    @NSManaged public var identityDocumentBackID: String?
    @NSManaged public var verification: Verification?
    @NSManaged public var taxYears: Set<TaxInfo>
    @NSManaged public var bankAccount: BankAccount?
    @NSManaged public var hasSetAvailability: Bool
    @NSManaged public var hasSetServiceRegion: Bool
    @NSManaged public var creationDate: Date

}

// MARK: Generated accessors for scheduleTimeSpans
extension Mechanic {

    @objc(addScheduleTimeSpansObject:)
    @NSManaged public func addToScheduleTimeSpans(_ value: TemplateTimeSpan)

    @objc(removeScheduleTimeSpansObject:)
    @NSManaged public func removeFromScheduleTimeSpans(_ value: TemplateTimeSpan)

    @objc(addScheduleTimeSpans:)
    @NSManaged public func addToScheduleTimeSpans(_ values: NSSet)

    @objc(removeScheduleTimeSpans:)
    @NSManaged public func removeFromScheduleTimeSpans(_ values: NSSet)

}

// MARK: Generated accessors for services
extension Mechanic {

    @objc(addServicesObject:)
    @NSManaged public func addToServices(_ value: AutoService)

    @objc(removeServicesObject:)
    @NSManaged public func removeFromServices(_ value: AutoService)

    @objc(addServices:)
    @NSManaged public func addToServices(_ values: NSSet)

    @objc(removeServices:)
    @NSManaged public func removeFromServices(_ values: NSSet)

}

// MARK: Generated accessors for transactions
extension Mechanic {
    
    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)
    
    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)
    
    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)
    
    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)
    
}
