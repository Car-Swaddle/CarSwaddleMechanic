//
//  Vehicle+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/15/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleNetworkRequest
import CoreLocation
import CoreData


public typealias VehicleCompletion = (_ vehicleObjectID: NSManagedObjectID?, _ error: Error?) -> Void

public class VehicleNetwork: Network {
    
    private var vehicleService: VehicleService
    
    override public init(serviceRequest: Request) {
        self.vehicleService = VehicleService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func requestVehicles(limit: Int = 100, offset: Int = 0, in context: NSManagedObjectContext, completion: @escaping (_ vehicleObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return vehicleService.getVehicles(limit: limit, offset: offset) { jsonArray, error in
            context.performOnImportQueue {
                var vehicleObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(vehicleObjectIDs, error)
                    }
                }
                
                for json in jsonArray ?? [] {
                    guard let vehicle = Vehicle.fetchOrCreate(json: json, context: context) else { continue }
                    if vehicle.objectID.isTemporaryID {
                        try? context.obtainPermanentIDs(for: [vehicle])
                    }
                    vehicleObjectIDs.append(vehicle.objectID)
                }
                
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func requestVehicle(vehicleID: String, in context: NSManagedObjectContext, completion: @escaping VehicleCompletion) -> URLSessionDataTask? {
        return vehicleService.getVehicle(vehicleID: vehicleID) { [weak self] json, error in
            self?.complete(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func createVehicle(name: String, licensePlate: String, state: String, in context: NSManagedObjectContext, completion: @escaping VehicleCompletion) -> URLSessionDataTask? {
        return vehicleService.postVehicle(name: name, licensePlate: licensePlate, state: state) { [weak self] json, error in
            self?.complete(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func createVehicle(name: String, vin: String, in context: NSManagedObjectContext, completion: @escaping VehicleCompletion) -> URLSessionDataTask? {
        return vehicleService.postVehicle(name: name, vin: vin) { [weak self] json, error in
            self?.complete(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func updateVehicle(vehicleID: String, name: String?, licensePlate: String?, state: String?, vin: String?, in context: NSManagedObjectContext, completion: @escaping VehicleCompletion) -> URLSessionDataTask? {
        return vehicleService.putVehicle(vehicleID: vehicleID, name: name, licensePlate: licensePlate, state: state, vin: vin) { [weak self] json, error in
            self?.complete(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func deleteVehicle(vehicleID: String, in context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return vehicleService.deleteVehicle(vehicleID: vehicleID) { error in
            context.performOnImportQueue {
                if error == nil {
                    if let vehicle = Vehicle.fetch(with: vehicleID, in: context) {
                        context.delete(vehicle)
                        context.persist()
                    }
                }
                completion(error)
            }
        }
    }
    
    
    private func complete(json: JSONObject?, error: Error?, in context: NSManagedObjectContext, completion: @escaping VehicleCompletion) {
        context.performOnImportQueue {
            var vehicleObjectID: NSManagedObjectID?
            defer {
                completion(vehicleObjectID, error)
            }
            
            guard let json = json,
                let vehicle = Vehicle.fetchOrCreate(json: json, context: context) else {
                    return
            }
            
            context.persist()
            
            vehicleObjectID = vehicle.objectID
        }
    }
    
    
}
