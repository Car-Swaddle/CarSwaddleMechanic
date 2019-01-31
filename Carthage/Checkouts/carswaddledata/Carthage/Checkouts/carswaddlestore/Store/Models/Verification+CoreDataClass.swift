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
    
}
