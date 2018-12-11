//
//  UserService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let users = Request.Endpoint(rawValue: "/api/users")
    fileprivate static let updateUser = Request.Endpoint(rawValue: "/api/update-user")
    fileprivate static let user = Request.Endpoint(rawValue: "/api/user")
    fileprivate static let currentUser = Request.Endpoint(rawValue: "/api/current-user")
}

public class UserService: Service {
    
    @discardableResult
    public func getUsers(offset: Int, limit: Int, completion: @escaping (_ json: [JSONObject]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let offsetItem = URLQueryItem(name: "offset", value: String(offset))
        let limitItem = URLQueryItem(name: "limit", value: String(limit))
        guard var urlRequest = serviceRequest.get(with: .users, queryItems: [offsetItem, limitItem]) else { return nil }
        
        try? urlRequest.authenticate()
        
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func getCurrentUser( completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard var urlRequest = serviceRequest.get(with: .currentUser) else { return nil }
        
        try? urlRequest.authenticate()
        
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func updateCurrentUser(firstName: String?, lastName: String?, phoneNumber: String?, token: String?, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        var json: JSONObject = [:]
        if let firstName = firstName {
            json["firstName"] = firstName
        }
        if let lastName = lastName {
            json["lastName"] = lastName
        }
        if let phoneNumber = phoneNumber {
            json["phoneNumber"] = phoneNumber
        }
        if let token = token {
            json["token"] = token
        }
        return updateCurrentUser(json: json, completion: completion)
    }
    
    @discardableResult
    public func updateCurrentUser(json: JSONObject, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard var urlRequest = serviceRequest.patch(with: .updateUser, body: body, contentType: .applicationJSON) else { return nil }
        
        try? urlRequest.authenticate()
        
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
}
