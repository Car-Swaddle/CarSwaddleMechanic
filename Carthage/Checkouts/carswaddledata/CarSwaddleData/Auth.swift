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
            self?.complete(json: json, token: token, error: error, context: context, completion: completion)
        }
    }
    
    @discardableResult
    public func mechanicLogin(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.mechanicLogin(email: email, password: password) { [weak self] json, token, error in
            self?.complete(json: json, token: token, error: error, context: context, completion: completion)
        }
    }
    
    private func complete(json: JSONObject?, token: String?, error: Error?, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) {
        context.performOnImportQueue { [weak self] in
            var error: Error? = error
            defer {
                completion(error)
            }
            if let json = json, let userJSON = json["user"] as? JSONObject {
                let user = User.fetchOrCreate(json: userJSON, context: context)
                if let userID = userJSON["id"] as? String ?? user?.identifier {
                    User.setCurrentUserID(userID)
                }
                if let mechanicJSON = json["mechanic"] as? JSONObject {
                    let mechanic = Mechanic.fetchOrCreate(json: mechanicJSON, context: context)
                    mechanic?.user = user
                    if let mechanicID = mechanic?.identifier {
                        Mechanic.setCurrentMechanicID(mechanicID)
                    }
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
    public func logout(deviceToken: String?, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        NotificationCenter.default.post(name: .willLogout, object: nil)
        let token = authentication.token
        let logoutService = authService.logout(deviceToken: deviceToken) { [weak self] error in
            self?.authentication.removeToken()
            NotificationCenter.default.post(name: .didLogout, object: ["previousToken": token])
            completion(error)
        }
        return logoutService
    }
    
    public var isLoggedIn: Bool {
        return authentication.token != nil
    }
    
}
