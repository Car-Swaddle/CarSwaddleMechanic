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
    fileprivate static let updateMechanic = Request.Endpoint(rawValue: "/api/update-mechanic")
    fileprivate static let currentMechanic = Request.Endpoint(rawValue: "/api/current-mechanic")
    fileprivate static let stats = Request.Endpoint(rawValue: "/api/stats")
    fileprivate static let mechanics = Request.Endpoint(rawValue: "/api/mechanics")
    fileprivate static let updateMechanicCorperate = Request.Endpoint(rawValue: "/api/update-mechanic/corperate")
}

final public class MechanicService: Service {
    
    @discardableResult
    public func getNearestMechanics(limit: Int, latitude: Double, longitude: Double, maxDistance: Double, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "latitude", value: "\(latitude)"),
                                          URLQueryItem(name: "longitude", value: "\(longitude)"),
                                          URLQueryItem(name: "maxDistance", value: "\(maxDistance)"),
                                          URLQueryItem(name: "limit", value: "\(limit)")]
        guard let urlRequest = serviceRequest.get(with: .nearestMechanic, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getCurrentMechanic(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .currentMechanic) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func updateCurrentMechanic(isActive: Bool?, token: String?, dateOfBirth: Date?, addressJSON: JSONObject?, externalAccount: String?, socialSecurityNumberLast4: String?, personalIDNumber: String?, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        var json: JSONObject = [:]
        if let isActive = isActive {
            json["isActive"] = isActive
        }
        if let token = token {
            json["token"] = token
        }
        if let dateOfBirth = dateOfBirth {
            json["dateOfBirth"] = serverDateFormatter.string(from: dateOfBirth)
        }
        if let addressJSON = addressJSON {
            json["address"] = addressJSON
        }
        if let externalAccount = externalAccount {
            json["externalAccount"] = externalAccount
        }
        if let socialSecurityNumberLast4 = socialSecurityNumberLast4 {
            json["ssnLast4"] = socialSecurityNumberLast4
        }
        if let personalIDNumber = personalIDNumber {
            json["personalID"] = personalIDNumber
        }
        
        return updateCurrentMechanic(json: json, completion: completion)
    }
    
    public static func addressJSON(line1: String, line2: String?, postalCode: String, city: String, state: String, country: String) -> JSONObject {
        return ["line1": line1, "line2": line2 ?? "", "postalCode": postalCode, "city": city, "state": state, "country": country]
    }
    
    @discardableResult
    public func updateCurrentMechanic(json: JSONObject, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard let urlRequest = serviceRequest.patch(with: .updateMechanic, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getStats(forMechanicWithID mechanicID: String, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let queryItems = [URLQueryItem(name: "mechanic", value: mechanicID)]
        guard let urlRequest = serviceRequest.get(with: .stats, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getMechanics(limit: Int = 30, offset: Int = 0, sortType: SortType = .descending, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: "\(limit)"),
                                          URLQueryItem(name: "offset", value: "\(offset)"),
                                          URLQueryItem(name: "sortType", value: "\(sortType.rawValue)")]
        guard let urlRequest = serviceRequest.get(with: .mechanics, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func updateMechanicCorperate(mechanicID: String, isAllowed: Bool? = nil, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "mechanicID", value: "\(mechanicID)")]
        var bodyJSON: JSONObject = [:]
        if let isAllowed = isAllowed {
            bodyJSON["isAllowed"] = isAllowed.stringValue
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])),
            let urlRequest = serviceRequest.post(with: .updateMechanicCorperate, queryItems: queryItems, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
