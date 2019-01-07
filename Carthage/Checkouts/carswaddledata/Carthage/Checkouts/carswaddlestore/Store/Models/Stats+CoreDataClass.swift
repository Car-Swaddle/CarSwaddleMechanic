//
//  Stats+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Stats)
public class Stats: NSManagedObject {
    
    convenience public init?(json: JSONObject, mechanicID: String, context: NSManagedObjectContext) {
        guard let averageRating = json["averageRating"] as? Double,
            let numberOfRatings = json["numberOfRatings"] as? Int,
            let autoServicesProvided = json["autoServicesProvided"] as? Int else { return nil }
        
        self.init(context: context)
        
        self.averageRating = averageRating
        self.numberOfRatings = numberOfRatings
        self.autoServicesProvided = autoServicesProvided
        
        if let mechanic = Mechanic.fetch(with: mechanicID, in: context) {
            self.mechanic = mechanic
        }
    }
    
}
