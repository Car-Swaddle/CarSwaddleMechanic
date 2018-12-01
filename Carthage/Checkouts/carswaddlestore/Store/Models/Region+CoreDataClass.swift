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

@objc(Region)
public final class Region: NSManagedObject, NSManagedObjectFetchable, JSONInitable {

    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let identifier = json["id"] as? String,
            let noTypeRadius = json["radius"] else { return nil }
        
        var radiusDouble = (noTypeRadius as? Double)
        if let radiusInt = noTypeRadius as? Int {
            radiusDouble = Double(radiusInt)
        }
        
        guard let radius = radiusDouble else { return nil }
        
        self.init(context: context)
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var centerCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
    
}
