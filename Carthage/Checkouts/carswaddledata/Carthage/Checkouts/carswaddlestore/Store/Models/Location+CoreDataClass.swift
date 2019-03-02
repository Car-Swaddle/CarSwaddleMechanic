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
    
    public static func fetchOrCreate(json: JSONObject, context: NSManagedObjectContext) -> Location? {
        if let identifier = json["id"] as? String {
            return fetch(with: identifier, in: context) ?? Location(json: json, context: context)
        } else {
            return Location(json: json, context: context)
        }
    }
    
    public static func fetch(with identifier: String, in context: NSManagedObjectContext) -> Location? {
        let fetchRequest: NSFetchRequest<Location> = NSFetchRequest(entityName: Location.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.fetchLimit = 2
        return Location.performFetch(with: fetchRequest, in: context)
    }
    
    fileprivate static func performFetch(with fetchRequest: NSFetchRequest<Location>, in context: NSManagedObjectContext) -> Location? {
        do {
            let objects = try context.fetch(fetchRequest)
            assert(objects.count < 2, "Location should be unique to identifier.")
            return objects.first
        } catch {
            return nil
        }
    }
    
    @NSManaged private var primitiveIdentifier: String
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let id = json.identifier else { return nil }
        let latitudeOptional = json["latitude"] as? Double
        let longitudeOptional = json["longitude"] as? Double
        
        let point = ((json["point"] as? JSONObject)?["coordinates"] as? [Double])
        
        let pointLongitude = point?.first
        let pointLatitude = (point?.count ?? 0) > 0 ? point?[1] : nil
        
        guard let longitude = longitudeOptional ?? pointLongitude,
            let latitude = latitudeOptional ?? pointLatitude else { return nil }
        
        self.init(context: context)
        self.identifier = id
        self.latitude = latitude
        self.longitude = longitude
        self.streetAddress = json["streetAddress"] as? String
    }
    
    public convenience init(context: NSManagedObjectContext, autoService: AutoService, coordinate: CLLocationCoordinate2D) {
        self.init(context: context)
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.autoService = autoService
    }
    
    public func toJSON(includeIdentifier: Bool = false) -> JSONObject {
        var json: JSONObject = [:]
        
        json["latitude"] = latitude
        json["longitude"] = longitude
        json["streetAddress"] = streetAddress
        
        if includeIdentifier {
            json["identifier"] = identifier
        }
        
        return json
    }
    
    public var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
