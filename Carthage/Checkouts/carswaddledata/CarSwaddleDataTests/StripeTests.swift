//
//  StripeTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData

class StripeTests: LoginTestCase {
    
    private let stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    func testRequestVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        self.stripeNetwork.requestVerification { verification, error in
            XCTAssert(verification != nil, "Should have fields needed")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
