//
//  User+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleNetworkRequest
import CoreData
import Store

public final class UserNetwork: Network {
    
    private lazy var userService = UserService(serviceRequest: self.serviceRequest)
    
    
    @discardableResult
    public func update(user: User, in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return update(firstName: user.firstName, lastName: user.lastName, phoneNumber: user.phoneNumber, in: context, completion: completion)
    }
    
    @discardableResult
    public func update(firstName: String?, lastName: String?, phoneNumber: String?, in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return userService.updateCurrentUser(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber) { json, error in
            context.perform {
                var userObjectID: NSManagedObjectID?
                defer {
                    completion(userObjectID, error)
                }
                
                guard let json = json else { return }
                let user = User.fetchOrCreate(json: json, context: context)
                context.persist()
                userObjectID = user?.objectID
            }
        }
    }
    
    
    @discardableResult
    public func requestCurrentUser(in context: NSManagedObjectContext, completion: @escaping (_ userObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return userService.getCurrentUser { json, error in
            context.perform {
                var userObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(userObjectID, error)
                    }
                }
                
                guard let json = json else { return }
                let user = User.fetchOrCreate(json: json, context: context)
                context.persist()
                userObjectID = user?.objectID
            }
        }
    }
    
    /*
     @discardableResult
     public func getNearestMechanics(limit: Int, latitude: Double, longitude: Double, maxDistance: Double, in context: NSManagedObjectContext, completion: @escaping (_ mechanicIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
     return mechanicService.getNearestMechanics(limit: limit, latitude: latitude, longitude: longitude, maxDistance: maxDistance) { [weak self] jsonArray, error in
     context.perform {
     var mechanicIDs: [NSManagedObjectID] = []
     defer {
     DispatchQueue.global().async {
     completion(mechanicIDs, error)
     }
     }
     guard let jsonArray = jsonArray else { return }
     
     for json in jsonArray {
     guard let mechanic = self?.createModel(from: json, in: context) else { continue }
     do {
     try context.obtainPermanentIDs(for: [mechanic])
     mechanicIDs.append(mechanic.objectID)
     } catch { print("unable to obtain permanent id") }
     }
     
     context.persist()
     }
     }
     }
     */
    
}
