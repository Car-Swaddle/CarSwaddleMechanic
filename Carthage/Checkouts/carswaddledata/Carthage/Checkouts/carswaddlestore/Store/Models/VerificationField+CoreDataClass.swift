//
//  VerificationField+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(VerificationField)
public class VerificationField: NSManagedObject {
    
    public convenience init(value: String, context: NSManagedObjectContext) {
        self.init(context: context)
        if Field(rawValue: value) == nil {
            print("Unknown VerificationField \(value). Creation of VerificationField will continue, but the type is unkown.")
        }
        self.value = value
    }
    
}
