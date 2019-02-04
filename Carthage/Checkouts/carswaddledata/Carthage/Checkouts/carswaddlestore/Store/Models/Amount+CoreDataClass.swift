//
//  Amount+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Amount)
public class Amount: NSManagedObject {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let value = json["amount"] as? Int,
            let currency = json["currency"] as? String else { return nil }
        
        self.init(context: context)
        
        self.value = value
        self.currency = currency
    }
    
    public var totalDollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(value)/100.0)
    }
    
}
