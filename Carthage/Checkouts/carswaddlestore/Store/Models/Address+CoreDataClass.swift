//
//  Address+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 12/25/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


typealias AddressValues = (identifier: String, line1: String?, line2: String?, postalCode: String?, city: String?, state: String?, country: String?, mechanicID: String?)

@objc(Address)
final public class Address: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Address.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Address.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        
        self.configure(with: values, in: context)
        
        if let mechanicID = json["mechanicID"] as? String {
            self.mechanic = Mechanic.fetch(with: mechanicID, in: context)
        }
    }
    
    static private func values(from json: JSONObject) -> AddressValues? {
        guard let identifier = json["id"] as? String else { return nil }
        
        let line1 = json["line1"] as? String
        let line2 = json["line2"] as? String
        let postalCode = json["postalCode"] as? String
        let city = json["city"] as? String
        let state = json["state"] as? String
        let country = json["country"] as? String
        
        return (identifier, line1, line2, postalCode, city, state, country, nil)
    }
    
    private func configure(with values: AddressValues, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.line1 = values.line1
        self.postalCode = values.postalCode
        self.city = values.city
        self.state = values.state
        self.country = values.country
        self.line2 = values.line2
        
        if let mechanicID = values.mechanicID {
            self.mechanic = Mechanic.fetch(with: mechanicID, in: context)
        }
    }
    
    public var toJSON: JSONObject {
        var json: JSONObject = [:]
        if let line1 = line1 {
            json["line1"] = line1
        }
        if let line2 = line2 {
            json["line2"] = line2
        }
        if let postalCode = postalCode {
            json["postalCode"] = postalCode
        }
        if let city = city {
            json["city"] = city
        }
        if let state = state {
            json["state"] = state
        }
        if let country = country {
            json["country"] = country
        }
        return json
    }
    
}
