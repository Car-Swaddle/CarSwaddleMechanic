//
//  AuthTestCase.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import Store

class AuthTestCase: XCTestCase {
    
    let authService = Auth(serviceRequest: serviceRequest)

    func testLogin() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            self.authService.login(email: "kyle@carswaddle.com", password: "password", context: pCtx) { error in
                XCTAssert(error == nil, "Should not have gotten an error")
                XCTAssert(User.currentUserID != nil, "No current mechanicID")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testMechanicLogin() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            self.authService.mechanicLogin(email: "kyle@carswaddle.com", password: "password", context: pCtx) { error in
                XCTAssert(error == nil, "Should not have gotten an error")
                XCTAssert(Mechanic.currentMechanicID != nil, "No current mechanicID")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}


class LogoutTests: LoginTestCase {
    
    let authService = Auth(serviceRequest: serviceRequest)
    
    func testLogout() {
        let exp = expectation(description: "The exp")
        authService.logout(deviceToken: "deviceToken") { error in
            XCTAssert(error == nil, "Should have no error: \(String(describing: error))")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
