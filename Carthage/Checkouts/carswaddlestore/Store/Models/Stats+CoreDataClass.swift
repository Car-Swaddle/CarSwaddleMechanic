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

private typealias StatsValues = (averageRating: Double, numberOfRatings: Int, autoServicesProvided: Int, mechanic: Mechanic)

@objc(Stats)
public class Stats: NSManagedObject {
    
    convenience public init?(json: JSONObject, mechanicID: String, context: NSManagedObjectContext) {
        guard let values = Stats.values(from: json, mechanicID: mechanicID, in: context) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    public func configure(with json: JSONObject, mechanicID: String) throws {
        guard let context = managedObjectContext,
            let values = Stats.values(from: json, mechanicID: mechanicID, in: context) else { throw StoreError.invalidJSON }
        configure(with: values)
    }
    
    private func configure(with values: StatsValues) {
        self.averageRating = values.averageRating
        self.numberOfRatings = values.numberOfRatings
        self.autoServicesProvided = values.autoServicesProvided
        self.mechanic = values.mechanic
    }
    
    private static func values(from json: JSONObject, mechanicID: String, in context: NSManagedObjectContext) -> StatsValues? {
        guard let averageRating = json["averageRating"] as? Double,
            let numberOfRatings = json["numberOfRatings"] as? Int,
            let autoServicesProvided = json["autoServicesProvided"] as? Int,
            let mechanic = Mechanic.fetch(with: mechanicID, in: context) else { return nil }
        
        return (averageRating, numberOfRatings, autoServicesProvided, mechanic)
    }
    
}
