//
//  AuthorityService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 6/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


import Foundation

extension NetworkRequest.Request.Endpoint {
    /*
     /api/authorities/request?authority=readAuthorities
     /api/authorities/reject
     /api/authorities/approve
     /api/authorities
     /api/authorityRequests?pending=false
     */
    fileprivate static let requestAuthority = Request.Endpoint(rawValue: "/api/authorities/request")
    fileprivate static let rejectAuthority = Request.Endpoint(rawValue: "/api/authorities/reject")
    fileprivate static let approveAuthority = Request.Endpoint(rawValue: "/api/authorities/approve")
    fileprivate static let authorities = Request.Endpoint(rawValue: "/api/authorities")
    fileprivate static let authorityRequests = Request.Endpoint(rawValue: "/api/authorityRequests")
    fileprivate static let currentUserAuthorities = Request.Endpoint(rawValue: "/api/authorities/user")
    fileprivate static let authorityTypes = Request.Endpoint(rawValue: "/api/authorities/types")
}

final public class AuthorityService: Service {
    
    @discardableResult
    public func getAuthorities(limit: Int? = nil, offset: Int? = nil, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        if let limit = limit {
            let limitQueryItem = URLQueryItem(name: "limit", value: String(limit))
            queryItems.append(limitQueryItem)
        }
        
        if let offset = offset {
            let offsetQueryItem = URLQueryItem(name: "offset", value: String(offset))
            queryItems.append(offsetQueryItem)
        }
        
        guard let urlRequest = serviceRequest.get(with: .authorities, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(jsonArray, error)
        }
    }
    
    @discardableResult
    public func getAuthorityRequests(limit: Int? = nil, offset: Int? = nil, pending: Bool? = nil, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        
        var queryItems: [URLQueryItem] = []
        
        if let limit = limit {
            let limitQueryItem = URLQueryItem(name: "limit", value: String(limit))
            queryItems.append(limitQueryItem)
        }
        
        if let offset = offset {
            let offsetQueryItem = URLQueryItem(name: "offset", value: String(offset))
            queryItems.append(offsetQueryItem)
        }
        
        if let pending = pending {
            let pendingQueryItem = URLQueryItem(name: "pending", value: String(pending))
            queryItems.append(pendingQueryItem)
        }
        
        guard let urlRequest = serviceRequest.get(with: .authorityRequests, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(jsonArray, error)
        }
    }
    
    @discardableResult
    public func getCurrentUserAuthorities(completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .currentUserAuthorities) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(jsonArray, error)
        }
    }
    
    @discardableResult
    public func requestAuthority(authority: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json = JSONObject()
        json["authority"] = authority
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .requestAuthority, body: body, contentType: .applicationJSON) else {
                completion(nil, NetworkRequestError.unableToCreateURLRequest)
                return nil
        }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func rejectAuthorityRequest(secretID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json = JSONObject()
        json["secretID"] = secretID
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .rejectAuthority, body: body, contentType: .applicationJSON) else {
                completion(nil, NetworkRequestError.unableToCreateURLRequest)
                return nil
        }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func approveAuthorityRequest(secretID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json = JSONObject()
        json["secretID"] = secretID
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .approveAuthority, body: body, contentType: .applicationJSON) else {
                completion(nil, NetworkRequestError.unableToCreateURLRequest)
                return nil
        }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getAuthorityTypes(completion: @escaping StringArrayCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .authorityTypes) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let stringArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String] else {
                    completion(nil, error)
                    return
            }
            completion(stringArray, error)
        }
    }
    
}

