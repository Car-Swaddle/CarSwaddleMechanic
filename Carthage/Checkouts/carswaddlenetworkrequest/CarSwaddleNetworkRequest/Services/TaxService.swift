//
//  TexService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let taxYears = Request.Endpoint(rawValue: "/api/tax-years")
    fileprivate static let taxes = Request.Endpoint(rawValue: "/api/taxes")
}

final public class TaxService: Service {
    
    @discardableResult
    public func getTaxYears(completion: @escaping (_ years: [String]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .taxYears) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let stringArray = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String] else {
                    completion(nil, error)
                    return
            }
            completion(stringArray, error)
        }
    }
    
    @discardableResult
    public func getTaxes(year: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let queryItems = [URLQueryItem(name: "taxYear", value: year)]
        guard let urlRequest = serviceRequest.get(with: .taxes, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
