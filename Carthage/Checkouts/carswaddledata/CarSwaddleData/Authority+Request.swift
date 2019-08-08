//
//  Authority+Request.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 6/18/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreData

final public class AuthorityNetwork: Network {
    
    private var authorityService: AuthorityService
    
    override public init(serviceRequest: Request) {
        self.authorityService = AuthorityService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getAuthorities(limit: Int? = nil, offset: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ authorityObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.getAuthorities(limit: limit, offset: offset) { jsonArray, error in
            context.performOnImportQueue {
                var authorityObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(authorityObjectIDs, error)
                    }
                }
                for authorityJSON in jsonArray ?? [] {
                    guard let authority = Authority.fetchOrCreate(json: authorityJSON, context: context) else { continue }
                    if authority.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [authority])
                    }
                    authorityObjectIDs.append(authority.objectID)
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func getAuthorityRequests(limit: Int? = nil, offset: Int? = nil, pending: Bool? = nil, in context: NSManagedObjectContext, completion: @escaping (_ authorityRequestObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.getAuthorityRequests(limit: limit, offset: offset, pending: pending) { jsonArray, error in
            context.performOnImportQueue {
                var authorityRequestObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(authorityRequestObjectIDs , error)
                    }
                }
                for authorityRequestJSON in jsonArray ?? [] {
                    guard let authorityRequest = AuthorityRequest.fetchOrCreate(json: authorityRequestJSON, context: context) else { continue }
                    if authorityRequest.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [authorityRequest])
                    }
                    authorityRequestObjectIDs.append(authorityRequest.objectID)
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func createAuthorityRequest(authority: String, in context: NSManagedObjectContext, completion: @escaping (_ authorityRequestObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.requestAuthority(authority: authority) { json, error in
            context.performOnImportQueue {
                var authorityRequestObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(authorityRequestObjectID , error)
                    }
                }
                guard let json = json,
                    let authorityRequest = AuthorityRequest.fetchOrCreate(json: json, context: context) else { return }
                context.persist()
                authorityRequestObjectID = authorityRequest.objectID
            }
        }
    }
    
    @discardableResult
    public func rejectAuthorityRequest(secretID: String, in context: NSManagedObjectContext, completion: @escaping (_ authorityConfirmationObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.rejectAuthorityRequest(secretID: secretID) { json, error in
            context.performOnImportQueue {
                var authorityConfirmationObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(authorityConfirmationObjectID , error)
                    }
                }
                guard let json = json,
                    let authorityConfirmation = AuthorityConfirmation.fetchOrCreate(json: json, context: context) else { return }
                context.persist()
                authorityConfirmationObjectID = authorityConfirmation.objectID
            }
        }
    }
    
    @discardableResult
    public func approveAuthorityRequest(secretID: String, in context: NSManagedObjectContext, completion: @escaping (_ authorityConfirmationObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.approveAuthorityRequest(secretID: secretID) { json, error in
            context.performOnImportQueue {
                var authorityConfirmationObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(authorityConfirmationObjectID, error)
                    }
                }
                guard let json = json,
                    let authorityConfirmation = AuthorityConfirmation.fetchOrCreate(json: json, context: context) else { return }
                context.persist()
                authorityConfirmationObjectID = authorityConfirmation.objectID
            }
        }
    }
    
    @discardableResult
    public func getCurrentUserAuthorities(in context: NSManagedObjectContext, completion: @escaping (_ authorityObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.getCurrentUserAuthorities { jsonArray, error in
            context.performOnImportQueue {
                var authorityObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(authorityObjectIDs , error)
                    }
                }
                for authorityJSON in jsonArray ?? [] {
                    guard let authority = Authority.fetchOrCreate(json: authorityJSON, context: context) else { continue }
                    if authority.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [authority])
                    }
                    authorityObjectIDs.append(authority.objectID)
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func getAuthorityTypes(completion: @escaping (_ authorityObjectIDs: [Authority.Name], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return authorityService.getAuthorityTypes { authorityTypes, error in
            var authorityNames: [Authority.Name] = []
            for type in authorityTypes ?? [] {
                authorityNames.append(Authority.Name(rawValue: type))
            }
            completion(authorityNames, error)
        }
    }
    
}
