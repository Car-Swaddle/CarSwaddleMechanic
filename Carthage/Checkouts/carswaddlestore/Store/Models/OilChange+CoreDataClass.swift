//
//  OilChange+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

@objc(OilChange)
public final class OilChange: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public static let defaultOilType: OilType = .synthetic
    
    public static let tempID = "localID"
    
    /// Must set ServiceEntity on your own. This does not set it and does not require it.
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let id = json.identifier,
            let oilTypeString = json["oilType"] as? String,
            let oilType = OilType(rawValue: oilTypeString) else { return nil }
        self.init(context: context)
        self.identifier = id
        self.oilType = oilType
    }
    
    public static func createWithDefaults(context: NSManagedObjectContext) -> OilChange {
        let oilChange = OilChange(context: context)
        oilChange.oilType = OilChange.defaultOilType
        oilChange.identifier = OilChange.tempID
        return oilChange
    }
    
    @NSManaged private var primitiveOilType: String
    @NSManaged private var primitiveIdentifier: String
    
    private static let oilTypeKey = "oilType"
    
    public var oilType: OilType {
        get {
            willAccessValue(forKey: OilChange.oilTypeKey)
            let value = OilType(rawValue: primitiveOilType)
            if value == nil {
                fatalError("Must have value for `\(primitiveOilType)`")
            }
            didAccessValue(forKey: OilChange.oilTypeKey)
            return value!
        }
        set {
            willChangeValue(forKey: OilChange.oilTypeKey)
            primitiveOilType = newValue.rawValue
            didChangeValue(forKey: OilChange.oilTypeKey)
        }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveOilType = OilChange.defaultOilType.rawValue
        primitiveIdentifier = OilChange.tempID
    }
    
    public func toJSON(includeIdentifier: Bool = false) -> JSONObject {
        var json: JSONObject = [:]
        json["oilType"] = oilType.rawValue
        if includeIdentifier {
            json["identifier"] = identifier
        }
        return json
    }
    
}
