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
        guard let urlRequest = serviceRequest.post(with: .region, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getRegion(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .region) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
