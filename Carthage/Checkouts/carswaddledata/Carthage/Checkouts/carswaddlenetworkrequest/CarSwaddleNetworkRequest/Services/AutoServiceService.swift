//
//  AutoService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let autoService = Request.Endpoint(rawValue: "/api/auto-service")
}

let serverDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

/// The service used to make requests to the server
public final class AutoServiceService: Service {
    
    @discardableResult
    public func createAutoService(autoServiceJSON: JSONObject, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let body = (try? JSONSerialization.data(withJSONObject: autoServiceJSON, options: [])),
            var urlRequest = serviceRequest.post(with: .autoService, body: body, contentType: .applicationJSON) else { return nil }
        do {
            try urlRequest.authenticate()
        } catch { print("couldn't authenticate") }
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
    public func getAutoServices(mechanicID: String, startDate: Date, endDate: Date, filterStatus: [String], completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "mechanicID", value: mechanicID),
            URLQueryItem(name: "startDate", value: serverDateFormatter.string(from: startDate)),
            URLQueryItem(name: "endDate", value: serverDateFormatter.string(from: endDate)),
        ]
        
        for singleStatus in filterStatus {
            let queryItem = URLQueryItem(name: "filterStatus", value: singleStatus)
            queryItems.append(queryItem)
        }
        
        guard var urlRequest = serviceRequest.get(with: .autoService, queryItems: queryItems, contentType: .applicationJSON) else { return nil }
        do {
            try urlRequest.authenticate()
        } catch { print("couldn't authenticate") }
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(jsonArray, error)
        }
    }
    
    @discardableResult
    public func getAutoServices(limit: Int, offset: Int, sortStatus: [String], completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
            ]
        
        for singleStatus in sortStatus {
            let queryItem = URLQueryItem(name: "sortStatus", value: singleStatus)
            queryItems.append(queryItem)
        }
        
        guard var urlRequest = serviceRequest.get(with: .autoService, queryItems: queryItems, contentType: .applicationJSON) else { return nil }
        do {
            try urlRequest.authenticate()
        } catch { print("couldn't authenticate") }
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let jsonArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
                    completion(nil, error)
                    return
            }
            completion(jsonArray, error)
        }
    }
    
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
