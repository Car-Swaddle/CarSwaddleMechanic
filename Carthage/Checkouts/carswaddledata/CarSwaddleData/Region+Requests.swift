//
//  Region+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData
import Store
import CarSwaddleNetworkRequest


public final class RegionNetwork: Network {
    
    private var regionService: RegionService
    
    override public init(serviceRequest: Request) {
        self.regionService = RegionService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func postRegion(region: Region, in context: NSManagedObjectContext, completion: @escaping (_ regionID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return postRegion(latitude: region.latitude, longitude: region.longitude, radius: region.radius, in: context, completion: completion)
    }
    
    @discardableResult
    public func postRegion(latitude: Double, longitude: Double, radius: Double, in context: NSManagedObjectContext, completion: @escaping (_ regionID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return regionService.postRegion(latitude: latitude, longitude: longitude, radius: radius) { json, error in
            context.performOnImportQueue {
                var regionObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(regionObjectID, error)
                    }
                }
                guard let json = json,
                    let regionJSON = json["region"] as? JSONObject else { return }
                let region = Region.fetchOrCreate(json: regionJSON, context: context)
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                if let previousRegion = mechanic?.serviceRegion {
                    context.delete(previousRegion)
                }
                region?.mechanic = mechanic
                context.persist()
                regionObjectID = region?.objectID
            }
        }
    }
    
    
    @discardableResult
    public func getRegion(in context: NSManagedObjectContext, completion: @escaping (_ regionID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return regionService.getRegion { json, error in
            context.performOnImportQueue {
                var regionObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(regionObjectID, error)
                    }
                }
                guard let json = json else { return }
                let region = Region.fetchOrCreate(json: json, context: context)
                context.persist()
                regionObjectID = region?.objectID
            }
        }
    }
    
}
