//
//  Auth.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Authentication
import CarSwaddleNetworkRequest
import CoreData
import Store

extension Notification.Name {
    static let willLogout = Notification.Name(rawValue: "CarSwaddleData.Auth.willLogout")
    static let didLogout = Notification.Name(rawValue: "CarSwaddleData.Auth.didLogout")
    
    static let didLogin = Notification.Name(rawValue: "CarSwaddleData.Auth.didLogin")
}

public class Auth {
    
    public let serviceRequest: Request
    
    lazy private var authService = AuthService(serviceRequest: serviceRequest)
    private let authentication = AuthController()
    
    public init(serviceRequest: Request) {
        self.serviceRequest = serviceRequest
    }
    
    @discardableResult
    public func signUp(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.signUp(email: email, password: password) { [weak self] json, token, error in
            self?.complete(json: json, token: token, error: error, context: context, completion: completion)
        }
    }
    
    @discardableResult
    public func login(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.login(email: email, password: password) { [weak self] json, token, error in
            self?.complete(json: json, token: token, error: error, context: context, completion: completion)
        }
    }
    
    @discardableResult
    public func mechanicSignUp(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.mechanicSignUp(email: email, password: password) { [weak self] json, token, error in
            self?.complete(json: json, isActive: true, token: token, error: error, context: context, completion: completion)
        }
    }
    
    @discardableResult
    public func mechanicLogin(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.mechanicLogin(email: email, password: password) { [weak self] json, token, error in
            self?.complete(json: json, token: token, error: error, context: context, completion: completion)
        }
    }
    
    private func complete(json: JSONObject?, isActive: Bool? = nil, token: String?, error: Error?, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) {
        context.perform { [weak self] in
            var error: Error?
            defer {
                completion(error)
            }
            if let json = json, let userJSON = json["user"] as? JSONObject,
                let userID = userJSON["id"] as? String {
                let user = User.fetchOrCreate(json: userJSON, context: context)
                User.setCurrentUserID(userID)
                if let mechanicJSON = json["mechanic"] as? JSONObject,
                    let mechanicID = mechanicJSON["id"] as? String {
                    let mechanic = Mechanic.fetch(with: mechanicID, in: context) ?? Mechanic(context: context)
                    mechanic.identifier = mechanicID
                    if let isActive = isActive {
                        mechanic.isActive = isActive
                    }
                    mechanic.user = user
                }
                context.persist()
            }
            if let token = token {
                self?.authentication.setToken(token)
                NotificationCenter.default.post(name: .didLogin, object: nil)
            }
        }
    }
    
    @discardableResult
    public func logout(completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        NotificationCenter.default.post(name: .willLogout, object: nil)
        let token = authentication.token
        authentication.removeToken()
        return authService.logout { error in
            NotificationCenter.default.post(name: .didLogout, object: ["previousToken": token])
            completion(error)
        }
    }
    
    public var isLoggedIn: Bool {
        return authentication.token != nil
    }
    
}
