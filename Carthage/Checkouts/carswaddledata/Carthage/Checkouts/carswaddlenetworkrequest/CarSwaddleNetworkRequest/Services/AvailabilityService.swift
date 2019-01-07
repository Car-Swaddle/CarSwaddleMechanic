//
//  TemplateTimeSpanService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

extension NetworkRequest.Request.Endpoint {
    fileprivate static let availability = Request.Endpoint(rawValue: "/api/availability")
//    fileprivate static let user = Request.Endpoint(rawValue: "/api/user")
//    fileprivate static let currentUser = Request.Endpoint(rawValue: "/api/current-user")
}


final public class AvailabilityService: Service {
    
    @discardableResult
    public func postAvailability(jsonArray: [JSONObject], completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        let json: JSONObject = ["spans": jsonArray]
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard let urlRequest = serviceRequest.post(with: .availability, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getAvailability(ofMechanicWithID mechanicID: String? = nil,  completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        
        var queryItems: [URLQueryItem] = []
        if let mechanicID = mechanicID {
            queryItems.append(URLQueryItem(name: "mechanicID", value: mechanicID))
        }
        
        guard let urlRequest = serviceRequest.get(with: .availability, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
    }
    
}
