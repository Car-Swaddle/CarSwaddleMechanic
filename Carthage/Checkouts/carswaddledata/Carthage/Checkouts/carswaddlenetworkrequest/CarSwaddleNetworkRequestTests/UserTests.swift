//
//  UserTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

#if targetEnvironment(simulator)
private let domain = "127.0.0.1"
#else
private let domain = "Kyles-MacBook-Pro.local"
#endif


class UserTests: CarSwaddleLoginTestCase {
    
    let userService = UserService(serviceRequest: serviceRequest)
    
    func testUpdateCurrentUserParameters() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(firstName: "Rupert", lastName: "Rolph", phoneNumber: "801-111-1111", token: nil, timeZone: "America/Denver") { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONFull() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONFull) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONName() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONName) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONFirstNameNumber() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONFirstNameNumber) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONLastNameNumber() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONLastNameNumber) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONFirstName() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONFirstName) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONLastName() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONLastName) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentUserJSONPhoneNumber() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(json: updateUserJSONPhoneNumber) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateService() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let service = self.userService
        
        let request = Request(domain: domain)
        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .http
        
        NotificationCenter.default.post(name: .serviceRequestDidChange, object: nil, userInfo: [Service.newServiceRequestKey: request])
        
        service.getCurrentUser { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testSendEmailVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.sendEmailVerificationEmail { json, error in
            XCTAssert(json?["email"] != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetCurrentUser() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.getCurrentUser { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testSendSMSVerification() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.sendSMSVerification { error in
            XCTAssert(error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testVerifySMS() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.verifySMS(withCode: "7386") { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}


let updateUserJSONFull: JSONObject = ["firstName": "Rupert", "lastName": "Rolph", "phoneNumber": "801-876-8271"]

let updateUserJSONName: JSONObject = ["firstName": "Rupert", "lastName": "Rolph"]
let updateUserJSONFirstNameNumber: JSONObject = ["firstName": "Rupert", "phoneNumber": "801-876-8271"]
let updateUserJSONLastNameNumber: JSONObject = ["lastName": "Rolph", "phoneNumber": "801-876-8271"]

let updateUserJSONFirstName: JSONObject = ["firstName": "Rupert"]
let updateUserJSONLastName: JSONObject = ["lastName": "Rolph"]
let updateUserJSONPhoneNumber: JSONObject = ["phoneNumber": "801-876-8271"]

