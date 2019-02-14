//
//  TaxServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class TaxServiceTests: XCTestCase {
    
    let taxService = TaxService(serviceRequest: serviceRequest)
    
    func testTaxYears() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        
        taxService.getTaxYears { stringArray, error in
            XCTAssert(stringArray != nil && error == nil, "Should get values")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testTaxInfo() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        taxService.getTaxes(year: "2019") { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
}
