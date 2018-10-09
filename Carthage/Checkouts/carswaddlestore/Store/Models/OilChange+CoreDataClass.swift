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
public final class OilChange: NSManagedObject, NSManagedObjectFetchable {
    
    public static let defaultOilType: OilType = .synthetic
    
    public static func createWithDefaults(context: NSManagedObjectContext) -> OilChange {
        let oilChange = OilChange(context: context)
        oilChange.oilType = OilChange.defaultOilType
        oilChange.identifier = UUID().uuidString
        return oilChange
    }
    
    @NSManaged private var primitiveOilType: String
    
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
    
}
