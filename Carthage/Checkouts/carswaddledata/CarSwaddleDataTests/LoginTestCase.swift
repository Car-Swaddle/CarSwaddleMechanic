//
//  LoginTestCase.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 10/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
//import CarSwaddleNetworkRequest
//import Authentication

class LoginTestCase: XCTestCase {

    let auth = Auth()
    
    override func setUp() {
        guard !auth.isLoggedIn else { return }
        let exp = expectation(description: "The exp")
        
        let context = store.mainContext
        auth.mechanicLogin(email: "k@k.com", password: "password", context: context) { error in
            print("in")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
