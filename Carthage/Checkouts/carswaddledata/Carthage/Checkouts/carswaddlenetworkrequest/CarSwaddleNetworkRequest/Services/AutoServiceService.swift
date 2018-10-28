//
//  AutoService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let services = Request.Endpoint(rawValue: "/hello")
    fileprivate static let user = Request.Endpoint(rawValue: "/user")
    fileprivate static let autoService = Request.Endpoint(rawValue: "/auto-service")
}

/// The service used to make requests to the server
public final class AutoServiceService: Service {
    
//    @discardableResult
//    public func getServer(with completion: @escaping (_ data: Data?, _ error: Error?)->()) -> URLSessionDataTask? {
//        let request = serverRequest.get(with: .services) { data, response, error in
//            completion(data, error)
//        }
////        let task = requ
////        try? request?.authenticate()
////        let task = request?.send(completion: completion)
//        return task
//    }
    
//    @discardableResult
//    public func postServer(with completion: @escaping (_ data: Data?, _ error: Error?)->()) -> URLSessionDataTask? {
//        let json = ["firstName": "First Dude",
//                    "lastName": "Last dude"]
//        let body = try! JSONSerialization.data(withJSONObject: json, options: [])
//        let task = serverRequest.post(with: .user, body: body) { data, response, error in
//            completion(data, error)
//        }
//        task?.resume()
//        return task
//    }
    
//    public func getScheduledAutoServices(with completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
//        let task = serverRequest.get(with: .autoService) { data, response, error in
//            completion(data, error)
//        }
//        task?.resume()
//        return task
//    }
    
//    public func getPastAutoServices(with completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
//        let queryItems = [URLQueryItem(name: "", value: "")]
//        return getAutoServices(queryItems: queryItems, with: completion)
//    }
//
//    public func getAutoServices(queryItems: [URLQueryItem], with completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
//        let task = serverRequest.get(with: .autoService, queryItems: queryItems) { data, response, error in
//            completion(data, error)
//        }
//        task?.resume()
//        return task
//    }
//
//    public func createNewAutoService(with completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
//        let json = ["firstName": "First Dude",
//                    "lastName": "Last dude"]
//        let body = try! JSONSerialization.data(withJSONObject: json, options: [])
//        let task = serverRequest.post(with: .user, body: body) { data, response, error in
//            completion(data, error)
//        }
//        task?.resume()
//        return task
//    }
    
}
