//
//  AuthTestCase.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData

class AuthTestCase: XCTestCase {
    
    let authService = Auth(serviceRequest: serviceRequest)

    func testLogin() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { pCtx in
            self.authService.login(email: "user@carswaddle.com", password: "password", context: pCtx) { error in
                XCTAssert(error == nil, "Should not have gotten an error")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }

}
