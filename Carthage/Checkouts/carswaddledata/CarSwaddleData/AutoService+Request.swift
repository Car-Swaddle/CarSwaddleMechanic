//
//  AutoService+Request.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreData
import MapKit


private let serverDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()


enum AutoServiceError: Error {
    case unableToGetJSON
}

public final class AutoServiceNetwork: Network {
    
    private var autoServiceService: AutoServiceService
    
    override public init(serviceRequest: Request) {
        self.autoServiceService = AutoServiceService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getAutoServiceDetails(autoServiceID: String, in context: NSManagedObjectContext, completion: @escaping (_ autoService: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return autoServiceService.getAutoServiceDetails(autoServiceID: autoServiceID) { json, error in
            context.performOnImportQueue {
                var autoServiceObjectID: NSManagedObjectID?
                defer {
                    completion(autoServiceObjectID, error)
                }
                
                guard let json = json else { return }
                let autoService = AutoService.fetchOrCreate(json: json, context: context)
                context.persist()
                autoServiceObjectID = autoService?.objectID
            }
        }
    }
    
    @discardableResult
    public func createAutoService(autoService originalAutoService: AutoService, sourceID: String, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let json = try? originalAutoService.toJSON() else {
            completion(nil, AutoServiceError.unableToGetJSON)
            return nil
        }
        return autoServiceService.createAutoService(autoServiceJSON: json, sourceID: sourceID) { [weak self] autoServiceJSON, error in
            self?.complete(originalAutoService: originalAutoService, error: error, autoServiceJSON: autoServiceJSON, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func getAutoServices(mechanicID: String, startDate: Date, endDate: Date, filterStatus: [AutoService.Status], in context: NSManagedObjectContext, completion: @escaping (_ autoServices: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return autoServiceService.getAutoServices(mechanicID: mechanicID, startDate: startDate, endDate: endDate, filterStatus: filterStatus.rawValues) { [weak self] jsonArray, error in
            self?.complete(error: error, jsonArray: jsonArray, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func getAutoServices(limit: Int, offset: Int, sortStatus: [AutoService.Status], in context: NSManagedObjectContext, completion: @escaping (_ autoServices: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return autoServiceService.getAutoServices(limit: limit, offset: offset, sortStatus: sortStatus.rawValues) { [weak self] jsonArray, error in
            self?.complete(error: error, jsonArray: jsonArray, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, status: AutoService.Status?, notes: String?, vehicleID: String?, mechanicID: String?, locationID: String?, location: CLLocationCoordinate2D?, scheduledDate: Date?, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        
        var json: JSONObject = [:]
        
        if let status = status { json["status"] = status.rawValue }
        if let notes = notes { json["notes"] = notes }
        if let vehicleID = vehicleID { json["vehicleID"] = vehicleID }
        if let mechanicID = mechanicID { json["mechanicID"] = mechanicID }
        if let locationID = locationID { json["locationID"] = locationID }
        if let scheduledDate = scheduledDate { json["scheduledDate"] = serverDateFormatter.string(from: scheduledDate) }
        if let location = location { json["location"] = ["longitude": location.longitude, "latitude": location.latitude] }
        
        return updateAutoService(autoServiceID: autoServiceID, json: json, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, status: AutoService.Status, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: status, notes: nil, vehicleID: nil, mechanicID: nil, locationID: nil, location: nil, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, notes: String, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: notes, vehicleID: nil, mechanicID: nil, locationID: nil, location: nil, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, vehicleID: String, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: nil, vehicleID: vehicleID, mechanicID: nil, locationID: nil, location: nil, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, mechanicID: String, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: nil, vehicleID: nil, mechanicID: mechanicID, locationID: nil, location: nil, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, locationID: String, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: nil, vehicleID: nil, mechanicID: nil, locationID: locationID, location: nil, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, location: CLLocationCoordinate2D, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: nil, vehicleID: nil, mechanicID: nil, locationID: nil, location: location, scheduledDate: nil, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, scheduledDate: Date, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return updateAutoService(autoServiceID: autoServiceID, status: nil, notes: nil, vehicleID: nil, mechanicID: nil, locationID: nil, location: nil, scheduledDate: scheduledDate, in: context, completion: completion)
    }
    
    @discardableResult
    public func updateAutoService(autoServiceID: String, json: JSONObject, in context: NSManagedObjectContext, completion: @escaping (_ autoServiceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return autoServiceService.updateAutoService(autoServiceID: autoServiceID, json: json) { [weak self] autoServiceJSON, error in
            self?.complete(originalAutoService: nil, error: error, autoServiceJSON: autoServiceJSON, in: context, completion: completion)
        }
    }
    
    private func complete(originalAutoService: AutoService?, error: Error?, autoServiceJSON: JSONObject?, in context: NSManagedObjectContext, completion: @escaping (_ autoService: NSManagedObjectID?, _ error: Error?) -> Void) {
        context.performOnImportQueue {
            var newAutoServiceObjectID: NSManagedObjectID?
            defer {
                DispatchQueue.global().async {
                    completion(newAutoServiceObjectID, error)
                }
            }
            
            guard let autoServiceJSON = autoServiceJSON else { return }
            if let originalAutoService = originalAutoService {
                context.delete(originalAutoService)
            }
            
            guard let convertedAutoService = AutoService.fetchOrCreate(json: autoServiceJSON, context: context) else { return }
            context.persist()
            newAutoServiceObjectID = convertedAutoService.objectID
        }
    }
    
    private func complete(error: Error?, jsonArray: [JSONObject]?, in context: NSManagedObjectContext, completion: @escaping (_ autoServices: [NSManagedObjectID], _ error: Error?) -> Void) {
        context.performOnImportQueue {
            var autoServiceIDs: [NSManagedObjectID] = []
            defer {
                DispatchQueue.global().async {
                    completion(autoServiceIDs, error)
                }
            }
            
            for json in jsonArray ?? [] {
                guard let autoService = AutoService.fetchOrCreate(json: json, context: context) else { continue }
                if autoService.objectID.isTemporaryID {
                    do {
                        try context.obtainPermanentIDs(for: [autoService])
                    } catch {
                        print(error)
                    }
                }
                autoServiceIDs.append(autoService.objectID)
            }
            context.persist()
        }
    }
    
}

fileprivate extension Array where Iterator.Element == AutoService.Status {
    
    fileprivate var rawValues: [String] {
        var values: [String] = []
        for value in self {
            values.append(value.rawValue)
        }
        return values
    }
    
}
