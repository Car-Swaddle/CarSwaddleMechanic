//
//  Region+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

typealias RegionValues = (latitude: Double, longitude: Double, identifier: String, radius: Double)

@objc(Region)
public final class Region: NSManagedObject, NSManagedObjectFetchable, JSONInitable {

    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Region.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Region.values(from: json) else { throw StoreError.invalidJSON }
        self.configure(with: values)
    }
    
    public var centerCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
    
    static private func values(from json: JSONObject) -> RegionValues? {
        guard let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let identifier = json["id"] as? String,
            let noTypeRadius = json["radius"] else { return nil }
        
        var radiusDouble = (noTypeRadius as? Double)
        if let radiusInt = noTypeRadius as? Int {
            radiusDouble = Double(radiusInt)
        }
        
        guard let radius = radiusDouble else { return nil }
        return (latitude, longitude, identifier, radius)
    }
    
    private func configure(with values: RegionValues) {
        self.identifier = values.identifier
        self.latitude = values.latitude
        self.longitude = values.longitude
        self.radius = values.radius
    }
    
}
