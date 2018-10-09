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
    fileprivate static let user = Request.Endpoint(rawValue: "/api/user")
    fileprivate static let currentUser = Request.Endpoint(rawValue: "/api/current-user")
}

public class UserService {
    
    public init() { }
    
    @discardableResult
    public func getUsers(offset: Int, limit: Int, completion: @escaping (_ json: [[String: Any]]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let offsetItem = URLQueryItem(name: "offset", value: String(offset))
        let limitItem = URLQueryItem(name: "limit", value: String(limit))
        var urlRequest = serverRequest.get(with: .users, queryItems: [offsetItem, limitItem])
        
        try? urlRequest?.authenticate()
        
        return urlRequest?.send { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]] else {
                    completion(nil, error)
                    return
            }
            completion(json, nil)
        }
    }
    
    @discardableResult
    public func getCurrentUser( completion: @escaping (_ json: [String: Any]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        var urlRequest = serverRequest.get(with: .currentUser)
        
        try? urlRequest?.authenticate()
        
        return urlRequest?.send { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                    completion(nil, error)
                    return
            }
            completion(json, nil)
        }
        
    }
    
}
