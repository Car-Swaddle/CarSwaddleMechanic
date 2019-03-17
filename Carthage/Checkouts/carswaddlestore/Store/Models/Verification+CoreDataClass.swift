//
//  Verification+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Verification)
public class Verification: NSManagedObject {
    
    public convenience init(json: JSONObject, context: NSManagedObjectContext) {
        self.init(context: context)
        self.disabledReason = json["disabled_reason"] as? String
        if let dueByDate = json["current_deadline"] as? Double {
            self.dueByDate = Date.init(timeIntervalSince1970: dueByDate)
        }
        let fieldsPastDue = json["past_due"] as? [String] ?? []
        let fieldsCurrentlyDue = json["currently_due"] as? [String] ?? []
        let fieldsEventuallyDue = json["eventually_due"] as? [String] ?? []
        
        self.pastDue = self.fields(from: fieldsPastDue, in: context)
        self.currentlyDue = self.fields(from: fieldsCurrentlyDue, in: context)
        self.eventuallyDue = self.fields(from: fieldsEventuallyDue, in: context)
    }
    
    private func fields(from strings: [String], in context: NSManagedObjectContext) -> Set<VerificationField> {
        var fieldsNeeded: Set<VerificationField> = []
        for fieldString in strings {
            let field = VerificationField(value: fieldString, context: context)
            fieldsNeeded.insert(field)
        }
        return fieldsNeeded
    }
    
    public var addressRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            if field == .addressCity || field == .addressState || field == .addressLine1 || field == .addressPostalCode {
                return true
            } else {
                return false
            }
        })
    }
    
    public var socialSecurityNumberRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            return field == .personalIDNumber
        })
    }
    
    public var last4OfSocialSecurityNumberRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            return field == .socialSecurityNumberLast4Digits
        })
    }
    
    public var bankAccountRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            return field == .externalAccount
        })
    }
    
    public var verificationDocumentRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            return field == .verificationDocument
        })
    }
    
    public var dateOfBirthRequired: Bool {
        return typedFieldsCurrentlyDue.contains(where: { (field) -> Bool in
            return field == .birthdayYear || field == .birthdayMonth || field == .birthdayDay
        })
    }
    
}
