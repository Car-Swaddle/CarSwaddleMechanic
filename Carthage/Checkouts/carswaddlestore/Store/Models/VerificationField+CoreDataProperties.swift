//
//  VerificationField+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension VerificationField {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VerificationField> {
        return NSFetchRequest<VerificationField>(entityName: VerificationField.entityName)
    }

    @NSManaged public var value: String
    @NSManaged public var verification: Verification?
    
    public var typedValue: Field? {
        guard let typeValue = Field(rawValue: value) else {
            assert(false, "Unable to convert \(value) as type `VerificationField.Value`")
            return nil
        }
        return typeValue
    }

    public enum Field: String, CaseIterable {
        /// The bank account used to transfer funds i.e. payout
        case externalAccount = "external_account"
        /// The city of the entity's address
        case addressCity = "legal_entity.address.city"
        /// The first line of the entity's address
        case addressLine1 = "legal_entity.address.line1"
        /// The postal code of the entity's address
        case addressPostalCode = "legal_entity.address.postal_code"
        /// The state of the entity's address
        case addressState = "legal_entity.address.state"
        /// The name of the business (only if type is company)
        case businessName = "legal_entity.business_name"
        /// The business tax ID of the business (only if type is company)
        case businessTaxID = "legal_entity.business_tax_id"
        /// The day of the month of the representative's/user's birth
        case birthdayDay = "legal_entity.dob.day"
        /// The month of the representative's/user's birth
        case birthdayMonth = "legal_entity.dob.month"
        /// The year of the representative's/user's birth
        case birthdayYear = "legal_entity.dob.year"
        /// The representative's/user's first name
        case firstName = "legal_entity.first_name"
        /// The representative's/user's last name
        case lastName = "legal_entity.last_name"
        /// The last 4 digits of the representative's/user's social security number
        case socialSecurityNumberLast4Digits = "legal_entity.ssn_last_4"
        /// The legal entity type (individual or company)
        case type = "legal_entity.type"
        /// The date the user accepted terms of service
        case termsOfServiceAcceptanceDate = "tos_acceptance.date"
        /// The IP address used when accepting terms of service
        case termsOfServiceIPAddress = "tos_acceptance.ip"
        /// Full Social Security Number
        case personalIDNumber = "legal_entity.personal_id_number"
        /// The document (passport or drivers license)
        case verificationDocument = "legal_entity.verification.document"
    }
    
}
