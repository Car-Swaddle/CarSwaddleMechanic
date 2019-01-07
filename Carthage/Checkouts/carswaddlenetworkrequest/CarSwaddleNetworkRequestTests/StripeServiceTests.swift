//
//  StripeServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 12/22/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest
import Authentication
import MapKit


class StripeServiceTests: CarSwaddleLoginTestCase {
    
    private let stripeService = StripeService(serviceRequest: serviceRequest)
    
    func testEphemeralKeys() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        stripeService.getKeys(apiVersion: "2018-11-08") { json, error in
            XCTAssert(json != nil, "Json is nil")
            XCTAssert(error == nil, "Got error: \(error?.localizedDescription ?? "")")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testStripeVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        stripeService.getVerification { json, error in
            XCTAssert(json != nil, "Json is nil")
            XCTAssert((json?["fields_needed"] as? [String]) != nil, "Does not have fields needed")
            XCTAssert(error == nil, "Got error: \(error?.localizedDescription ?? "")")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
