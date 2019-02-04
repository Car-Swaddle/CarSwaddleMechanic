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
        if let dueByDate = json["due_by"] as? Double {
            self.dueByDate = Date.init(timeIntervalSince1970: dueByDate)
        }
        let fieldsNeededStrings = json["fields_needed"] as? [String] ?? []
        var fieldsNeeded: Set<VerificationField> = []
        for fieldString in fieldsNeededStrings {
            let field = VerificationField(value: fieldString, context: context)
            fieldsNeeded.insert(field)
        }
        self.fields = fieldsNeeded
    }
    
    public var addressRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            if field == .addressCity || field == .addressState || field == .addressLine1 || field == .addressPostalCode {
                return true
            } else {
                return false
            }
        })
    }
    
    public var socialSecurityNumberRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            return field == .personalIDNumber
        })
    }
    
    public var last4OfSocialSecurityNumberRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            return field == .socialSecurityNumberLast4Digits
        })
    }
    
    public var bankAccountRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            return field == .externalAccount
        })
    }
    
    public var verificationDocumentRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            return field == .verificationDocument
        })
    }
    
    public var dateOfBirthRequired: Bool {
        return typedFieldsNeeded.contains(where: { (field) -> Bool in
            return field == .birthdayYear || field == .birthdayMonth || field == .birthdayDay
        })
    }
    
}
