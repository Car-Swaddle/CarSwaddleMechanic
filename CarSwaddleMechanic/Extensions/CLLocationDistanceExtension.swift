//
//  CLLocationDistanceExtension.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreLocation
import MapKit

extension CLLocationDistance {
    
    static let mile: CLLocationDistance = 1609.34
    static let yard: CLLocationDistance = 0.9144
    static let foot: CLLocationDistance = 0.3048
    static let inch: CLLocationDistance = 0.0254
    
    static let kilometer: CLLocationDistance = 1000
    static let centimeter: CLLocationDistance = 0.01
    static let millimeter: CLLocationDistance = 0.001
    
    private static let milesToMetersConstant: CLLocationDistance = 1609.344
    private static let metersToMilesConstant: CLLocationDistance = 0.00062137
    
    var kilometersToMeters: CLLocationDistance {
        return self * 1000
    }
    
    var metersToMiles: CLLocationDistance {
        return self * CLLocationDistance.metersToMilesConstant
    }
    
    var milesToMeters: CLLocationDistance {
        return self * CLLocationDistance.milesToMetersConstant
    }
    
}

extension CLLocationDegrees {
    static let kilometersPerLongitudinalDegree: Double = 111
}

extension MKCoordinateRegion {
    
    var longitudinalDistance: CLLocationDistance {
        let northLocation = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let southLocation = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        return northLocation.distance(from: southLocation)
    }
    
    var latitudinalDistance: CLLocationDistance {
        let eastLocation = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let westLocation = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        return eastLocation.distance(from: westLocation)
    }
    
}

extension MKCoordinateSpan {
    
    var longitudinalKilometers: CLLocationDistance {
        return longitudeDelta * .kilometersPerLongitudinalDegree
    }
    
}
