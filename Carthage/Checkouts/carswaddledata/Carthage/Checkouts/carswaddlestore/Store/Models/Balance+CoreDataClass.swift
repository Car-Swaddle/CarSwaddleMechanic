//
//  Balance+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Balance)
public class Balance: NSManagedObject {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let availableArray = json["available"] as? [JSONObject],
            let pendingArray = json["pending"] as? [JSONObject] else { return nil }
        
        self.init(context: context)
        
        guard let availableJSON = availableArray.first, let available = Amount(json: availableJSON, context: context),
            let pendingJSON = pendingArray.first, let pending = Amount(json: pendingJSON, context: context) else {
                return
        }
        self.available = available
        self.pending = pending
        
        if let reservedArray = json["connect_reserved"] as? [JSONObject],
            let reservedJSON = reservedArray.first,
            let reserved = Amount(json: reservedJSON, context: context) {
            self.reserved = reserved
        }
    }
    
}
