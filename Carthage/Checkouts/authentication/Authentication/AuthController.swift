//
//  AuthController.swift
//  Authentication
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

//import CarSwaddleNetworkRequest
import KeychainAccess

private let authKeychainService = "com.carSwaddle.CarSwaddle"
private let tokenKey = "com.carswaddle.keychainAuthTokenKey"

public class AuthController {
    
    public init() {}
    
    private let keychain = Keychain(service: authKeychainService)
    
    public func setToken(_ token: String) {
        try? keychain.set(token, key: tokenKey)
    }
    
    public func removeToken() {
        try? keychain.remove(tokenKey)
    }
    
    public var token: String? {
        do {
            return try keychain.get(tokenKey)
        } catch {
            print("error trying to fetch token: \(error)")
            return nil
        }
    }
    
}
