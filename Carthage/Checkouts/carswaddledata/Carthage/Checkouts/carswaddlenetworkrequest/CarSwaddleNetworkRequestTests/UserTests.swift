//
//  UserTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class UserTests: CarSwaddleLoginTestCase {
    
    let userService = UserService(serviceRequest: serviceRequest)
    
    func testUpdateCurrentUserParameters() {
        let exp = expectation(description: "\(#function)\(#line)")
        userService.updateCurrentUser(firstName: "Rupert", lastName: "Rolph", phoneNumber: "801-111-1111") { json, error in
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
    
}


let updateUserJSONFull: JSONObject = ["firstName": "Rupert", "lastName": "Rolph", "phoneNumber": "801-876-8271"]

let updateUserJSONName: JSONObject = ["firstName": "Rupert", "lastName": "Rolph"]
let updateUserJSONFirstNameNumber: JSONObject = ["firstName": "Rupert", "phoneNumber": "801-876-8271"]
let updateUserJSONLastNameNumber: JSONObject = ["lastName": "Rolph", "phoneNumber": "801-876-8271"]

let updateUserJSONFirstName: JSONObject = ["firstName": "Rupert"]
let updateUserJSONLastName: JSONObject = ["lastName": "Rolph"]
let updateUserJSONPhoneNumber: JSONObject = ["phoneNumber": "801-876-8271"]

