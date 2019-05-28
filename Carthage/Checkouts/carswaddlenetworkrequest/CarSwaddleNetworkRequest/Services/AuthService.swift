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
    fileprivate static let logout = Request.Endpoint(rawValue: "/api/logout")
    fileprivate static let signup = Request.Endpoint(rawValue: "/signup")
    fileprivate static let requestUpdatePassword = Request.Endpoint(rawValue: "/api/request-reset-password")
    fileprivate static let setNewPassword = Request.Endpoint(rawValue: "/api/reset-password")
}

public class AuthService: Service {
    
    @discardableResult
    public func signUp(email: String, password: String, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, password: password, isMechanic: false, endpoint: .signup) { [weak self] data, error in
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
    public func requestUpdatePassword(email: String, app: App, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return requestUpdatePassword(email: email, appName: app.rawValue, completion: completion)
    }
    
    @discardableResult
    public func requestUpdatePassword(email: String, appName: String, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(email: email, appName: appName, endpoint: .requestUpdatePassword) { [weak self] data, error in
            var json: JSONObject?
            var error = error
            defer {
                completion(json, error)
            }
            guard let data = data,
                let responseJSON = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    error = NetworkRequestError.invalidJSON
                    return
            }
            json = responseJSON
        }
        task?.resume()
        return task
    }
    
    @discardableResult
    public func setNewPassword(newPassword: String, token: String, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = authTask(newPassword: newPassword, resetToken: token, endpoint: .setNewPassword) { [weak self] data, error in
            var json: JSONObject?
            var error = error
            defer {
                completion(json, error)
            }
            guard let data = data,
                let responseJSON = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    error = NetworkRequestError.invalidJSON
                    return
            }
            json = responseJSON
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
    public func logout(deviceToken: String?, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        var json: JSONObject = [:]
        if let deviceToken = deviceToken {
            json["deviceToken"] = deviceToken
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .logout, body: body, contentType: .applicationJSON) else { return nil }
        let task = self.sendWithAuthentication(urlRequest: urlRequest) { data, error in
            completion(error)
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
    
    private func complete(data: Data?, error: Error?, completion: @escaping (_ json: JSONObject?, _ token: String?, _ error: Error?) -> Void) {
        var json: JSONObject?
        var error: Error? = error
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
        guard let body = serielizedData(email: email, password: password) else {
            return nil
        }
        
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "isMechanic", value: isMechanic.stringValue)]
        guard let request = serviceRequest.post(with: endpoint, queryItems: queryItems, body: body) else { return nil }
        return serviceRequest.send(urlRequest: request, completion: completion)
    }
    
    
    private func authTask(newPassword: String, resetToken: String, endpoint: NetworkRequest.Request.Endpoint, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = serielizedData(newPassword: newPassword, resetToken: resetToken) else {
            return nil
        }
        
        guard let request = serviceRequest.post(with: endpoint, body: body) else { return nil }
        return serviceRequest.send(urlRequest: request, completion: completion)
    }
    
    private func authTask(email: String, appName: String, endpoint: NetworkRequest.Request.Endpoint, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        guard let body = serielizedData(email: email, appName: appName) else {
            return nil
        }
        
        guard let request = serviceRequest.post(with: endpoint, body: body) else { return nil }
        return serviceRequest.send(urlRequest: request, completion: completion)
    }
    
    private func serielizedData(email: String? = nil, password: String? = nil, newPassword: String? = nil, resetToken: String? = nil, appName: String? = nil) -> Data? {
        
        var bodyString = ""
        var previousValueExists = false
        
        if let email = email {
            bodyString += "email=\(email.urlEscaped())"
            previousValueExists = true
        }
        
        if let password = password {
            if previousValueExists {
                bodyString += "&"
            }
            bodyString += "password=\(password)"
            previousValueExists = true
        }
        
        if let newPassword = newPassword {
            if previousValueExists {
                bodyString += "&"
            }
            bodyString += "newPassword=\(newPassword)"
            previousValueExists = true
        }
        
        if let resetToken = resetToken {
            if previousValueExists {
                bodyString += "&"
            }
            bodyString += "token=\(resetToken.urlEscaped())"
            previousValueExists = true
        }
        
        if let appName = appName {
            if previousValueExists {
                bodyString += "&"
            }
            bodyString += "appName=\(appName.urlEscaped())"
            previousValueExists = true
        }
        
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
