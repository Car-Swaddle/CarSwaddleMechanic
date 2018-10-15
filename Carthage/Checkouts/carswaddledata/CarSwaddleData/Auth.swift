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

public class Auth {
    
    private let authService = AuthService()
    private let authentication = AuthController()
    
    public init() { }
    
    @discardableResult
    public func signUp(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.signUp(email: email, password: password) { [weak self] userJSON, token, error in
            self?.complete(userJSON: userJSON, token: token, error: error, context: context, completion: completion)
        }
    }
    
    @discardableResult
    public func login(email: String, password: String, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return authService.login(email: email, password: password) { [weak self] userJSON, token, error in
            self?.complete(userJSON: userJSON, token: token, error: error, context: context, completion: completion)
        }
    }
    
    private func complete(userJSON: JSONObject?, token: String?, error: Error?, context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) {
        context.perform { [weak self] in
            var error: Error?
            defer {
                completion(error)
            }
            if let userJSON = userJSON, let userID = userJSON["id"] as? String {
                _ = User(json: userJSON, context: context)
                User.setCurrentUserID(userID)
                context.persist()
            }
            if let token = token {
                self?.authentication.setToken(token)
            }
        }
    }
    
    @discardableResult
    public func logout(completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        authentication.removeToken()
        return authService.logout(completion: completion)
    }
    
}
