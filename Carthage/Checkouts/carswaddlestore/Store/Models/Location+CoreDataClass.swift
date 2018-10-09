//
//  Location+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData
import CoreLocation

@objc(Location)
public final class Location: NSManagedObject {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public convenience init(context: NSManagedObjectContext, autoService: AutoService, coordinate: CLLocationCoordinate2D) {
        self.init(context: context)
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.autoService = autoService
    }

}
