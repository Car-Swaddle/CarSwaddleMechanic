//
//  Mechanic+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData
import Store
import CarSwaddleNetworkRequest
import CoreLocation

public typealias ObjectIDCompletion = (_ objectID: NSManagedObjectID?, _ error: Error?) -> Void
public typealias ObjectIDArrayCompletion = (_ objectIDs: [NSManagedObjectID], _ error: Error?) -> Void


public final class MechanicNetwork: Network {
    
    private var mechanicService: MechanicService
    private var fileService: FileService
    
    override public init(serviceRequest: Request) {
        self.mechanicService = MechanicService(serviceRequest: serviceRequest)
        self.fileService = FileService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getNearestMechanics(limit: Int, coordinate: CLLocationCoordinate2D, maxDistance: Double, in context: NSManagedObjectContext, completion: @escaping ObjectIDArrayCompletion) -> URLSessionDataTask? {
        return getNearestMechanics(limit: limit, latitude: coordinate.latitude, longitude: coordinate.longitude, maxDistance: maxDistance, in: context, completion: completion)
    }
    
    @discardableResult
    public func update(isActive: Bool? = nil, token: String? = nil, dateOfBirth: Date? = nil, address: Address? = nil, externalAccount: String? = nil, socialSecurityNumberLast4: String? = nil, personalIDNumber: String? = nil, in context: NSManagedObjectContext, completion: @escaping ObjectIDCompletion) -> URLSessionDataTask? {
        let addressJSON: JSONObject? = address?.toJSON
        return mechanicService.updateCurrentMechanic(isActive: isActive, token: token, dateOfBirth: dateOfBirth, addressJSON: addressJSON, externalAccount: externalAccount, socialSecurityNumberLast4: socialSecurityNumberLast4, personalIDNumber: personalIDNumber) { [weak self] json, error in
            self?.completeMechanic(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func getStats(mechanicID: String, in context: NSManagedObjectContext, completion: @escaping ObjectIDCompletion) -> URLSessionDataTask? {
        return mechanicService.getStats(forMechanicWithID: mechanicID) { json, error in
            context.performOnImportQueue {
                var mechanicObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicObjectID, error)
                    }
                }
                
                guard let json = json?[mechanicID] as? JSONObject else { return }
                var stats: Stats?
                if let previousStats = Mechanic.fetch(with: mechanicID, in: context)?.stats {
                    try? previousStats.configure(with: json, mechanicID: mechanicID)
                    stats = previousStats
                } else {
                    stats = Stats(json: json, mechanicID: mechanicID, context: context)
                }
                context.persist()
                mechanicObjectID = stats?.mechanic?.objectID
            }
        }
    }
    
    private func completeMechanic(json: JSONObject?, error: Error?, in context: NSManagedObjectContext, completion: @escaping ObjectIDCompletion) {
        context.performOnImportQueue {
            var mechanicObjectID: NSManagedObjectID?
            defer {
                DispatchQueue.global().async {
                    completion(mechanicObjectID, error)
                }
            }
            
            guard let json = json else { return }
            let mechanic = Mechanic.fetchOrCreate(json: json, context: context)
            context.persist()
            mechanicObjectID = mechanic?.objectID
        }
    }
    
    @discardableResult
    public func getCurrentMechanic(in context: NSManagedObjectContext, completion: @escaping ObjectIDCompletion) -> URLSessionDataTask? {
        return mechanicService.getCurrentMechanic { [weak self] json, error in
            self?.completeMechanic(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func getNearestMechanics(limit: Int, latitude: Double, longitude: Double, maxDistance: Double, in context: NSManagedObjectContext, completion: @escaping ObjectIDArrayCompletion) -> URLSessionDataTask? {
        return mechanicService.getNearestMechanics(limit: limit, latitude: latitude, longitude: longitude, maxDistance: maxDistance) { [weak self] jsonArray, error in
            context.performOnImportQueue {
                var mechanicIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicIDs, error)
                    }
                }
                guard let jsonArray = jsonArray else { return }
                
                for json in jsonArray {
                    guard let mechanic = self?.createModel(from: json, in: context) else { continue }
                    if mechanic.objectID.isTemporaryID {
                        try? context.obtainPermanentIDs(for: [mechanic])
                    }
                    mechanicIDs.append(mechanic.objectID)
                }
                
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func setProfileImage(fileURL: URL, in context: NSManagedObjectContext, completion: @escaping (_ mechanicObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return fileService.uploadMechanicProfileImage(fileURL: fileURL) { json, error in
            context.performOnImportQueue {
                var mechanicObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicObjectID, error)
                    }
                }
                
                if let mechanicID = Mechanic.currentLoggedInMechanic(in: context)?.identifier {
                    _ = try? profileImageStore.storeFile(url: fileURL, mechanicID: mechanicID)
                }
                
                guard let currentMechanic = Mechanic.currentLoggedInMechanic(in: context), error == nil else { return }
                currentMechanic.profileImageID = json?["profileImageID"] as? String
                context.persist()
                mechanicObjectID = currentMechanic.objectID
            }
        }
    }
    
    @discardableResult
    public func uploadIdentityDocument(fileURL: URL, side: DocumentSide? = nil, in context: NSManagedObjectContext, completion: @escaping (_ mechanicObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return fileService.uploadMechanicIdentityDocument(fileURL: fileURL, side: side?.rawValue) { json, error in
            context.performOnImportQueue {
                var mechanicObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicObjectID, error)
                    }
                }
                
                guard let currentMechanic = Mechanic.currentLoggedInMechanic(in: context), error == nil else { return }
                currentMechanic.identityDocumentID = json?["identityDocumentID"] as? String
                context.persist()
                mechanicObjectID = currentMechanic.objectID
            }
        }
    }
    
    
    @discardableResult
    public func getProfileImage(mechanicID: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return fileService.getMechanicProfileImage(mechanicID: mechanicID) { url, responseError in
            var completionError: Error? = responseError
            var permanentURL: URL?
            defer {
                completion(permanentURL, completionError)
            }
            guard let url = url else { return }
            do {
                permanentURL = try profileImageStore.storeFile(url: url, mechanicID: mechanicID)
            } catch { completionError = error }
        }
    }
    
    
    
    private func createModel(from json: JSONObject, in context: NSManagedObjectContext) -> Mechanic? {
        var regionJSON: JSONObject = json
        regionJSON["id"] = json["regionID"] as? String
        
        let region = Region.fetchOrCreate(json: regionJSON, context: context)
        
        let mechanic = Mechanic.fetchOrCreate(json: json, context: context)
        mechanic?.serviceRegion = region
        
        var userJSON: JSONObject = json
        userJSON["id"] = json["userID"] as? String
        
        let user = User.fetchOrCreate(json: userJSON, context: context)
        user?.mechanic = mechanic
        
        return mechanic
    }
    
    
    @discardableResult
    public func getMechanics(limit: Int = 30, offset: Int = 0, sortType: SortType = .descending, in context: NSManagedObjectContext, completion: @escaping ObjectIDArrayCompletion) -> URLSessionDataTask? {
        return mechanicService.getMechanics(limit: limit, offset: offset, sortType: sortType) { [weak self] jsonArray, error in
            context.performOnImportQueue {
                var mechanicIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(mechanicIDs, error)
                    }
                }
                guard let jsonArray = jsonArray else { return }
                for json in jsonArray {
                    guard let mechanic = self?.createModel(from: json, in: context) else { continue }
                    if mechanic.objectID.isTemporaryID {
                        try? context.obtainPermanentIDs(for: [mechanic])
                    }
                    mechanicIDs.append(mechanic.objectID)
                }
                
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func updateMechanicCorperate(mechanicID: String, isAllowed: Bool? = nil, in context: NSManagedObjectContext, completion: @escaping ObjectIDCompletion) -> URLSessionDataTask? {
        return mechanicService.updateMechanicCorperate(mechanicID: mechanicID, isAllowed: isAllowed) { [weak self] json, error in
            self?.completeMechanic(json: json, error: error, in: context, completion: completion)
        }
    }
    
}


extension MechanicNetwork {
    
    public enum DocumentSide: String {
        case front
        case back
    }
    
}
