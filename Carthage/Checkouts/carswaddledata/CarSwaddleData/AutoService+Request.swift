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

public final class AutoServiceNetwork: Network {
    
    private var autoServiceService: AutoServiceService
    
    override public init(serviceRequest: Request) {
        self.autoServiceService = AutoServiceService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func createAutoService(autoService: AutoService, in context: NSManagedObjectContext, completion: @escaping (_ autoService: AutoService?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let json = try? autoService.toJSON() else { return nil }
        return autoServiceService.createAutoService(autoServiceJSON: json) { autoServiceJSON, error in
            context.perform {
                var newAutoService: AutoService?
                defer {
                    DispatchQueue.global().async {
                        completion(newAutoService, error)
                    }
                }
                
                guard let autoServiceJSON = autoServiceJSON else { return }
                context.delete(autoService)
                
                guard let convertedAutoService = AutoService.fetchOrCreate(json: autoServiceJSON, context: context) else { return }
                newAutoService = convertedAutoService
                context.persist()
            }
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
    
    private func complete(error: Error?, jsonArray: [JSONObject]?, in context: NSManagedObjectContext, completion: @escaping (_ autoServices: [NSManagedObjectID], _ error: Error?) -> Void) {
        context.perform {
            var autoServiceIDs: [NSManagedObjectID] = []
            defer {
                DispatchQueue.global().async {
                    completion(autoServiceIDs, error)
                }
            }
            
            for json in jsonArray ?? [] {
                guard let autoService = AutoService.fetchOrCreate(json: json, context: context) else { continue }
                if autoService.objectID.isTemporaryID {
                    try? context.obtainPermanentIDs(for: [autoService])
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
