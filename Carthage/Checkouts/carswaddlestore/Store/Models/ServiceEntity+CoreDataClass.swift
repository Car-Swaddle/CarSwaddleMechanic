//
//  ServiceEntity+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 11/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias ServiceEntityValues = (identifier: String, entityType: ServiceEntity.EntityType)

@objc(ServiceEntity)
final public class ServiceEntity: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public static let tempID = "tempID"
    
    public enum EntityType: String, CaseIterable {
        case oilChange = "OIL_CHANGE"
        
        public var localizedString: String {
            switch self {
            case .oilChange:
                return NSLocalizedString("Oil Change", comment: "Type of oil change")
            }
        }
        
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveIdentifier = ServiceEntity.tempID
    }
    
    @NSManaged private var primitiveIdentifier: String
    
    /// Must set actual eneity relationship on your own. It is not set here and does not require it.
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = ServiceEntity.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json)
    }
    
    public convenience init(autoService: AutoService, oilChange: OilChange, context: NSManagedObjectContext) {
        self.init(context: context)
        self.autoService = autoService
        self.oilChange = oilChange
        self.entityType = .oilChange
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = ServiceEntity.values(from: json) else { throw StoreError.invalidJSON }
        configure(with: values, json: json)
    }
    
    private func configure(with values: ServiceEntityValues, json: JSONObject) {
        self.identifier = values.identifier
        self.entityType = values.entityType
        
        guard let context = managedObjectContext else { return }
        
        if let autoServiceID = json["autoServiceID"] as? String,
            let autoService = AutoService.fetch(with: autoServiceID, in: context) {
            self.autoService = autoService
        }
        
        switch entityType {
        case .oilChange:
            if let oilChangeJSON = json["oilChange"] as? JSONObject,
                let oilChange = OilChange.fetchOrCreate(json: oilChangeJSON, context: context) {
                self.oilChange = oilChange
            }
        }
    }
    
    private let entityTypeKey = "entityType"
    @NSManaged private var primitiveEntityType: String
    
    public var entityType: EntityType {
        set {
            willChangeValue(forKey: entityTypeKey)
            primitiveEntityType = newValue.rawValue
            didChangeValue(forKey: entityTypeKey)
        }
        get {
            willAccessValue(forKey: entityTypeKey)
            let enumValue = EntityType(rawValue: primitiveEntityType) ?? .oilChange
            didAccessValue(forKey: entityTypeKey)
            return enumValue
        }
    }
    
    public func toJSON(includeIdentifier: Bool = false, includeEntityIdentifier: Bool = false) -> JSONObject {
        var entityJSON: JSONObject = [:]
        entityJSON["entityType"] = entityType.rawValue
        switch entityType {
        case .oilChange:
            if let oilChange = oilChange {
                entityJSON["specificService"] = oilChange.toJSON(includeIdentifier: includeEntityIdentifier)
            }
        }
        
        if includeIdentifier {
            entityJSON["identifier"] = identifier
        }
        
        return entityJSON
    }
    
    
    private static func values(from json: JSONObject) -> ServiceEntityValues? {
        guard let id = json.identifier,
            let entityTypeString = json["entityType"] as? String,
            let entityType = EntityType(rawValue: entityTypeString) else { return nil }
        return (id, entityType)
    }
    
}

public extension Sequence where Iterator.Element == ServiceEntity {
    
    public func toJSONArray(includeIdentifiers: Bool = false, includeEntityIdentifiers: Bool = false) -> [JSONObject] {
        var jsonArray: [JSONObject] = []
        for entity in self {
            jsonArray.append(entity.toJSON(includeIdentifier: includeIdentifiers, includeEntityIdentifier: includeEntityIdentifiers))
        }
        return jsonArray
    }
    
}
