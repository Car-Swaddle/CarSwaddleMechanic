//
//  AuthorityTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 6/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class AuthorityTests: CarSwaddleLoginTestCase {
    
    let authorityService = AuthorityService(serviceRequest: serviceRequest)
    
    func testRequestAuthority() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let uuid = UUID().uuidString
        authorityService.requestAuthority(authority: "someAuthority" + uuid) { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRejectAuthority() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.rejectAuthorityRequest(secretID: "2247a6a0-8fe3-11e9-b9af-59e2b1d24ffb") { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            XCTAssert(json?["authorityID"] == nil, "Should not have had authority")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testApproveAuthority() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.approveAuthorityRequest(secretID: "1e433ff1-8fe4-11e9-b9af-59e2b1d24ffb") { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            XCTAssert(json?["authorityName"] != nil, "Should have had authorityName")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestAuthorities() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.getAuthorities { jsonArray, error in
            XCTAssert(jsonArray?.count != 0 && error == nil, "Should get values")
            jsonArray?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestAuthorityRequests() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.getAuthorities { jsonArray, error in
            XCTAssert(jsonArray?.count != 0 && error == nil, "Should get values")
            jsonArray?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetCurrentUserAuthorities() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.getCurrentUserAuthorities { jsonArray, error in
            XCTAssert(jsonArray?.count != 0 && error == nil, "Should get values")
            jsonArray?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAuthorityTypes() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authorityService.getAuthorityTypes { stringArray, error in
            XCTAssert(stringArray?.count != 0 && error == nil, "Should get values")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
}


extension JSONObject {
    func printObject() {
        print(self)
    }
}

extension Array where Iterator.Element == JSONObject {
    func printObject() {
        for json in self {
            json.printObject()
        }
    }
}
