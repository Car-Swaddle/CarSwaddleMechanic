//
//  RegionService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let region = Request.Endpoint(rawValue: "/api/region")
}


final public class RegionService: Service {
    
    @discardableResult
    public func postRegion(latitude: Double, longitude: Double, radius: Double, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let json: JSONObject = ["latitude": latitude, "longitude": longitude, "radius": radius]
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard var urlRequest = serviceRequest.post(with: .region, body: body, contentType: .applicationJSON) else { return nil }
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
    public func getRegion(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard var urlRequest = serviceRequest.get(with: .region) else { return nil }
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
    
//    @discardableResult
//    public func getAvailability(completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
//        var urlRequest = serverRequest.get(with: .region)
//        do {
//            try urlRequest?.authenticate()
//        } catch { print("couldn't authenticate") }
//        return urlRequest?.send { data, error in
//            guard let data = data,
//                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [JSONObject] else {
//                    completion(nil, error)
//                    return
//            }
//            completion(json, nil)
//        }
//    }
    
}
