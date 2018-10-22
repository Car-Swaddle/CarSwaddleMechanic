//
//  AuthService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let login = Request.Endpoint(rawValue: "/login")
    fileprivate static let signup = Request.Endpoint(rawValue: "/signup")
}

public class AuthService: Service {
    
    @discardableResult
    public func signUp(email: String, password: String, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, password: password, isMechanic: true, endpoint: .signup) { [weak self] data, error in
            self?.complete(data: data, error: error, completion: completion)
        }
        task?.resume()
        return task
    }
    
    @discardableResult
    public func mechanicSignUp(email: String, password: String, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, password: password, isMechanic: true, endpoint: .signup) { [weak self] data, error in
            self?.complete(data: data, error: error, completion: completion)
        }
        task?.resume()
        return task
    }
    
    @discardableResult
    public func login(email: String, password: String, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, password: password, isMechanic: false, endpoint: .login) { [weak self] data, error in
            self?.complete(data: data, error: error, completion: completion)
        }
        task?.resume()
        return task
    }
    
    @discardableResult
    public func mechanicLogin(email: String, password: String, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, password: password, isMechanic: true, endpoint: .login) { [weak self] data, error in
            self?.complete(data: data, error: error, completion: completion)
        }
        task?.resume()
        return task
    }
    
    @discardableResult
    public func logout(completion: (_ error: Error?) -> Void) -> URLSessionDataTask? {
        // TODO: Logout on server
        return nil
    }
    
    private func complete(data: Data?, error: Error?, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) {
        var json: JSONObject?
        var error: Error?
        var token: String?
        defer {
            completion(json, token, error)
        }
        guard let data = data,
            let responseJSON = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                error = NetworkRequestError.invalidJSON
                return
        }
        token = responseJSON["token"] as? String
        json = [:]
        if let userJSON = responseJSON["user"] as? JSONObject {
            json?["user"] = userJSON
        }
        if let mechanicJSON = responseJSON["mechanic"] as? JSONObject {
            json?["mechanic"] = mechanicJSON
        }
    }
    
    private func authTask(email: String, password: String, isMechanic: Bool, endpoint: NetworkRequest.Request.Endpoint, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = serielizedData(from: email, password: password) else {
            return nil
        }
        
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "isMechanic", value: true.stringValue)]
        let request = serverRequest.post(with: endpoint, queryItems: queryItems, body: body)
        
        return request?.send(completion: completion)
    }
    
    private func serielizedData(from email: String, password: String) -> Data? {
        let bodyString = "email=\(email.urlEscaped())&password=\(password)"
        return bodyString.data(using: .utf8)
    }
    
}

extension String {
    
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - returns: The percent-escaped string.
    func urlEscaped() -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
    }
}
