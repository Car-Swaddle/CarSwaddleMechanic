//
//  CarSwaddleNetworkRequestTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class CarSwaddleLoginTestCase: XCTestCase {
    
    private let authService = AuthService()
    
    override func setUp() {
        loginIfNeeded()
    }
    
    private func loginIfNeeded() {
        guard authentication.token == nil else { return }
        
        let exp = expectation(description: "\(#function)\(#line)")
        authService.mechanicLogin(email: "k@k.com", password: "password") { json, token, error in
            if let token = token {
                authentication.setToken(token)
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
