//
//  MechanicService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 11/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

extension NetworkRequest.Request.Endpoint {
    fileprivate static let nearestMechanic = Request.Endpoint(rawValue: "/api/nearest-mechanics")
}

final public class MechanicService: Service {
    
    @discardableResult
    public func getNearestMechanics(limit: Int, latitude: Double, longitude: Double, maxDistance: Double, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "latitude", value: "\(latitude)"),
                                          URLQueryItem(name: "longitude", value: "\(longitude)"),
                                          URLQueryItem(name: "maxDistance", value: "\(maxDistance)"),
                                          URLQueryItem(name: "limit", value: "\(limit)")]
        guard var urlRequest = serviceRequest.get(with: .nearestMechanic, queryItems: queryItems) else { return nil }
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
    
}
