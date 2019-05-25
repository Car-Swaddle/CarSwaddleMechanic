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
    fileprivate static let sendEmailVerification = Request.Endpoint(rawValue: "/api/email/send-verification")
    fileprivate static let sendSMSVerification = Request.Endpoint(rawValue: "/api/sms/send-verification")
    fileprivate static let verifySMS = Request.Endpoint(rawValue: "/api/sms/verify")
}

public class UserService: Service {
    
    @discardableResult
    public func getUsers(offset: Int, limit: Int, completion: @escaping (_ json: [JSONObject]?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let offsetItem = URLQueryItem(name: "offset", value: String(offset))
        let limitItem = URLQueryItem(name: "limit", value: String(limit))
        guard let urlRequest = serviceRequest.get(with: .users, queryItems: [offsetItem, limitItem]) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getCurrentUser( completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .currentUser) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func sendEmailVerificationEmail(completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .sendEmailVerification) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func sendSMSVerification(completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .sendSMSVerification) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            completion(error)
        }
    }
    
    @discardableResult
    public func verifySMS(withCode code: String, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let codeItem = URLQueryItem(name: "code", value: code)
        guard let urlRequest = serviceRequest.get(with: .verifySMS, queryItems: [codeItem]) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func updateCurrentUser(firstName: String?, lastName: String?, phoneNumber: String?, token: String?, timeZone: String?, adminKey: String? = nil, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
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
        if let timeZone = timeZone {
            json["timeZone"] = timeZone
        }
        if let adminKey = adminKey {
            json["adminKey"] = adminKey
        }
        return updateCurrentUser(json: json, completion: completion)
    }
    
    @discardableResult
    public func updateCurrentUser(json: JSONObject, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard let urlRequest = serviceRequest.patch(with: .updateUser, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
