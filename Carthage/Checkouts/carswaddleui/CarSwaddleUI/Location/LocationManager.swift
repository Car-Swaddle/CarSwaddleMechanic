//
//  LocationManager.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreLocation
import Contacts
import UIKit
import MapKit


extension Notification.Name {
    public static let changedLocationAuthorizationStatus =  Notification.Name(rawValue: "changedLocationAuthorizationStatus")
}

public enum LocationError: Error {
    case noAccess
    case accessNotRequested
    case backgroundTaskTimeout
}


/// Thin layer around CLLocationManager providing a simpler API and caching.
final public class LocationManager: NSObject {
    
    public override init() {
        super.init()
        coreLocationManager.delegate = self
    }
    
    /// Describes how to fetch the location
    ///
    /// - cacheElseNetwork: Will first try to use the cached object. If it's past the provided maxAge or does not exist, it will attempt to fetch users current location.
    /// - cacheOnly: Will only get a cached location. If doesn't exist, or the location is past the provided maxAge, it will return with nothing in the completion.
    /// - networkOnly: Will only attempt to get the users current location.
    public enum LocationCacheOptions {
        case cacheElseNetwork(maxAge: TimeInterval?)
        case cacheOnly(maxAge: TimeInterval?)
        case networkOnly
    }
    
    
    public var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func promptUserForLocationAccess() {
        coreLocationManager.requestWhenInUseAuthorization()
    }
    
    /**
     Gets the user's current address
     
     - parameter completion: optionally returns CLLocation
     
     */
    public func currentLocation(cacheOptions: LocationCacheOptions, _ completion: @escaping ((_ location: CLLocation?, _ error: Error?) -> Void)) {
        assert(Thread.isMainThread, "Must be on main thread when calling this method \(#function)")
        if case .cacheElseNetwork(let maxAge) = cacheOptions {
            if let location = self.lastCachedLocationIfValid(forMaxAge: maxAge) {
                completion(location, nil)
                return
            }
        } else if case .cacheOnly(let maxAge) = cacheOptions {
            if let location = self.lastCachedLocationIfValid(forMaxAge: maxAge) {
                completion(location, nil)
            } else {
                completion(nil, nil)
            }
            return
        }
        guard let canBeFetched = authorizationStatus.locationCanBeFetched else {
            completion(nil, LocationError.accessNotRequested)
            return
        }
        guard canBeFetched else {
            completion(nil, LocationError.noAccess)
            return
        }
        locationCompletions.append(completion)
        coreLocationManager.requestLocation()
        
        let task = UIApplication.shared.beginBackgroundTask(withName: "Fetch user location", expirationHandler: { [weak self] in
            self?.callLocationUpdateCompletions(with: nil, error: LocationError.backgroundTaskTimeout)
        })
        fetchLocationTasks.append(task)
    }
    
    public func placemarks(fromAddress address: String, completion: @escaping (_ placemarks: [CLPlacemark]?, _ error: Error?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            completion(placemarks, error)
        }
    }
    
    /**
     Gets the user's current address
     
     - parameter completion: optionally returns String
     */
    public func currentAddress(cacheOptions: LocationCacheOptions = .networkOnly, _ completion: @escaping ((_ address: String?, _ error: Error?) -> Void)) {
        currentLocationPlacemark(cacheOptions: cacheOptions) { placemark, error in
            completion(placemark?.localizedAddress, error)
        }
    }
    
    /// Fetches placemark from the location if available. Uses cache options to determine how to fetch the location first. Then will get the placemark from a location.
    public func currentLocationPlacemark(cacheOptions: LocationCacheOptions = .networkOnly, _ completion: @escaping ((_ placemark: CLPlacemark?, _ error: Error?) -> Void)) {
        currentLocation(cacheOptions: cacheOptions) { [weak self] location, error in
            guard let _self = self,
                let location = location else {
                    completion(nil, error)
                    return
            }
            
            let reverseGeocode = {
                self?.placemark(from: location) { placemark, error in
                    completion(placemark, error)
                }
            }
            
            switch cacheOptions {
            case .networkOnly:
                reverseGeocode()
            case .cacheOnly(_):
                if let placemark = _self.reverseGeocodeLocationCache[location] {
                    completion(placemark, nil)
                } else {
                    completion(nil, nil)
                }
            case .cacheElseNetwork(_):
                if let placemark = _self.reverseGeocodeLocationCache[location] {
                    completion(placemark, nil)
                } else {
                    reverseGeocode()
                }
            }
        }
    }
    
    public func placemark(from location: CLLocation, completion: @escaping ((_ placemark: CLPlacemark?, _ error: Error?) -> Void)) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            var completionPlacemark: CLPlacemark?
            defer {
                self?.lastFetchedPlacemark = completionPlacemark
                completion(completionPlacemark, error)
            }
            guard let placemark = placemarks?.first else { return }
            completionPlacemark = placemark
            self?.reverseGeocodeLocationCache[location] = placemark
        }
    }
    
    private func requestRouteRequest(_ routeRequest: RouteRequest, finish: @escaping () -> Void) {
        
        routeRequest.wasCanceled = { [weak self] in
            self?.geocoder.cancelGeocode()
            routeRequest.directions?.cancel()
        }
        
        if routeRequest.isCanceled {
            routeRequest.completion(nil, nil)
            finish()
        }
        
        placemark(from: routeRequest.sourceLocation) { [weak self] destinationPlacemark, error in
            guard let destinationPlacemark = destinationPlacemark, self != nil, !routeRequest.isCanceled else {
                routeRequest.completion(nil, error)
                finish()
                return
            }
            self?.placemark(from: routeRequest.destinationLocation) { sourcePlacemark, error in
                guard let sourcePlacemark = sourcePlacemark, self != nil, !routeRequest.isCanceled else {
                    routeRequest.completion(nil, error)
                    finish()
                    return
                }
                let directions = self?.requestDirections(sourcePlacemark: sourcePlacemark, destinationPlacemark: destinationPlacemark) { directions, error in
                    routeRequest.completion(directions?.routes.first, error)
                    finish()
                }
                routeRequest.directions = directions
            }
        }
    }
    
    @discardableResult
    public func requestDirections(sourcePlacemark: CLPlacemark, destinationPlacemark: CLPlacemark, completion: @escaping (_ route: MKDirections.Response?, _ error: Error?) -> Void) -> MKDirections {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(placemark: sourcePlacemark))
        request.destination = MKMapItem(placemark: MKPlacemark(placemark: destinationPlacemark))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate { directions, error in
            completion(directions, error)
        }
        return directions
    }
    
    public func queueRouteRequest(routeRequest: RouteRequest) {
        if routeRequests.count == 0 {
            routeRequests.insert(routeRequest, at: 0)
            startRouteRequest(routeRequest: routeRequest) { }
        } else {
            routeRequests.insert(routeRequest, at: 0)
        }
    }
    
    private func startRouteRequest(routeRequest: RouteRequest, finish: @escaping () -> Void) {
        requestRouteRequest(routeRequest) { [weak self] in
            if self?.routeRequests.isEmpty == false {
                self?.routeRequests.removeLast()
            }
            guard let self = self, let nextRouteRequest = self.routeRequests.last else {
                finish()
                return
            }
            self.startRouteRequest(routeRequest: nextRouteRequest) { }
        }
    }
    
    private var routeRequests: [RouteRequest] = []
    
    public func cachedPlacemark(for location: CLLocation) -> CLPlacemark? {
        return reverseGeocodeLocationCache[location]
    }
    
    public let geocoder = CLGeocoder()
    private var fetchLocationTasks: [UIBackgroundTaskIdentifier] = []
    private let coreLocationManager = CLLocationManager()
    private var locationCompletions: [((CLLocation?, Error?) -> Void)] = []
    private var reverseGeocodeLocationCache: [CLLocation: CLPlacemark] = [:]
    public private(set) var lastFetchedPlacemark: CLPlacemark?
    
    private func callLocationUpdateCompletions(with location: CLLocation?, error: Error?) {
        for completion in locationCompletions {
            completion(location, error)
        }
        self.locationCompletions.removeAll()
        for task in fetchLocationTasks {
            UIApplication.shared.endBackgroundTask(task)
        }
        if let location = location {
            UserDefaults.setLocation(location: location)
        }
    }
    
    private func lastCachedLocationObject() -> LocationCacheObject? {
        return UserDefaults.fetchLastLocation()
    }
    
    private func lastCachedLocationIfValid(forMaxAge maxAge: TimeInterval?) -> CLLocation? {
        guard let cacheObject = lastCachedLocationObject() else { return nil }
        guard let maxAge = maxAge else { return cacheObject.location }
        if cacheObject.cacheDate.timeIntervalSince(Date()) <= maxAge {
            return cacheObject.location
        } else {
            return nil
        }
    }
    
}

public class RouteRequest {
    
    public init(sourceLocation: CLLocation, destinationLocation: CLLocation, completion: @escaping (_ route: MKRoute?, _ error: Error?) -> Void) {
        self.sourceLocation = sourceLocation
        self.destinationLocation = destinationLocation
        self.completion = completion
    }
    
    public var sourceLocation: CLLocation
    public var destinationLocation: CLLocation
    public var completion: (_ route: MKRoute?, _ error: Error?) -> Void
    
    fileprivate var directions: MKDirections?
    fileprivate var wasCanceled: () -> Void = {}
    fileprivate var isCanceled: Bool = false
    
    public func cancel() {
        isCanceled = true
        wasCanceled()
    }
    
}

extension UserDefaults {
    
    private static let cachedLocationKey = "cachedLocationKey"
    
    /// Fetches the last cached location
    fileprivate class func fetchLastLocation() -> LocationCacheObject? {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.cachedLocationKey) else { return nil }
        return (try? JSONDecoder().decode(LocationCacheObject.self, from: data))
    }
    
    /// Stores the provided location
    fileprivate class func setLocation(location: CLLocation) {
        let object = LocationCacheObject(location: location, cacheDate: Date())
        if let data = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(data, forKey: UserDefaults.cachedLocationKey)
        }
    }
    
    static private let numberOfLocationRequestShowsKey = "numberOfLocationRequestShowsKey"
    static private let numberOfSettingsRequestShowsKey = "numberOfSettingsRequestShowsKey"
    
    fileprivate static func numberOfTimesAllowLocationRequestShown() -> Int {
        return UserDefaults.standard.integer(forKey: numberOfLocationRequestShowsKey)
    }
    
    fileprivate static func numberOfTimesAllowLocationInSettingsRequestShown() -> Int {
        return UserDefaults.standard.integer(forKey: numberOfSettingsRequestShowsKey)
    }
    
    fileprivate static func didShowAllowLocationRequest() {
        let previousValue = UserDefaults.numberOfTimesAllowLocationRequestShown()
        UserDefaults.standard.set(previousValue+1, forKey: numberOfLocationRequestShowsKey)
    }
    
    fileprivate static func didShowAllowLocationInSettingsRequest() {
        let previousValue = UserDefaults.numberOfTimesAllowLocationInSettingsRequestShown()
        UserDefaults.standard.set(previousValue+1, forKey: numberOfSettingsRequestShowsKey)
    }
    
}

fileprivate struct LocationCacheObject: Codable {
    
    /// A CLLocation object from the objects lat and long
    fileprivate var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /// Latitude of the cached location
    fileprivate let latitude: Double
    /// longitude of the cached location
    fileprivate let longitude: Double
    
    /// The initial date the object was cached
    fileprivate let cacheDate: Date
    
    fileprivate init(location: CLLocation, cacheDate: Date) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.cacheDate = cacheDate
    }
    
    fileprivate init(latitude: Double, longitude: Double, cacheDate: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.cacheDate = cacheDate
    }
    
}


extension LocationManager: CLLocationManagerDelegate {
    
    // MARK: - Authorization Changes
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(name: .changedLocationAuthorizationStatus, object: ["status": status])
    }
    
    // MARK: - Location Updates
    
    @objc public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        callLocationUpdateCompletions(with: locations.first, error: nil)
    }
    
    @objc public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        callLocationUpdateCompletions(with: nil, error: error)
    }
    
}

extension CLAuthorizationStatus {
    
    /// Simpler way of knowing if the current location is able to be fetched.
    public var locationCanBeFetched: Bool? {
        switch self {
        case .notDetermined:
            return nil
        case .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            fatalError("unkown presentation style")
        }
    }
    
}


extension CLPlacemark {
    
    /// Address from a placemark
    fileprivate var localizedAddress: String? {
        let address = CNMutablePostalAddress()
        address.state = administrativeArea ?? ""
        address.city = locality ?? ""
        
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
    
}





