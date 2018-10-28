//
//  Region+CoreDataProperties.swift
//  Store
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: Region.entityName)
    }
    
    @objc public var latitude: CGFloat {
        get {
            willAccessValue(forKey: #keyPath(Region.latitude))
            let value = primitiveValue(forKey: #keyPath(Region.latitude)) as! Float
            didAccessValue(forKey: #keyPath(Region.latitude))
            return CGFloat(value)
        }
        set {
            willChangeValue(for: \.latitude)
            setPrimitiveValue(Float(newValue), forKey: #keyPath(Region.latitude))
            didChangeValue(for: \.latitude)
        }
    }
    
    @objc public var longitude: CGFloat {
        get {
            willAccessValue(forKey: #keyPath(Region.longitude))
            let value = primitiveValue(forKey: #keyPath(Region.longitude)) as! Float
            didAccessValue(forKey: #keyPath(Region.longitude))
            return CGFloat(value)
        }
        set {
            willChangeValue(forKey: #keyPath(Region.longitude))
            setPrimitiveValue(Float(newValue), forKey: #keyPath(Region.longitude))
            didChangeValue(forKey: #keyPath(Region.longitude))
        }
    }

    @NSManaged public var identifier: String
    @NSManaged public var radius: Double
    @NSManaged public var mechanic: Mechanic?

}
