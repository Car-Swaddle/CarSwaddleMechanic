//
//  LoginTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

private let password = "password"

class LoginTests: XCTestCase {
    
    private let authService = AuthService(serviceRequest: serviceRequest)
    
    func testLogin() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.login(email: "user@carswaddle.com", password: password) { json, token, error in
            XCTAssert(token != nil, "Should have logged in")
            XCTAssert(json?["mechanic"] == nil, "Should not have mechanic")
            XCTAssert(json?["user"] != nil, "Should have user")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testLoginIncorrectPass() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.login(email: "user@carswaddle.com", password: "some incorrect pass") { json, token, error in
            XCTAssert(token == nil, "Should not have logged in incorrect pass")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testLoginIncorrectEmail() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.login(email: "ktsjdkf@kasdgjh.com", password: password) { json, token, error in
            XCTAssert(token == nil, "Should not have logged in incorrect email")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    /// Keep this here, but only uncomment if you want to create a new user
//    func testSignUp() {
//        let exp = expectation(description: "\(#function)\(#line)")
//
//        let newEmail = UUID().uuidString
//        authService.signUp(email: newEmail + "@k.com", password: password) { json, token, error in
//            XCTAssert(token != nil, "Should have logged in")
//            XCTAssert(json?["mechanic"] == nil, "Should have mechanic")
//            XCTAssert(json?["user"] != nil, "Should have user")
//            exp.fulfill()
//        }
//
//        waitForExpectations(timeout: 40, handler: nil)
//    }
    
    func testSignUpExistingEmailFails() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.signUp(email: "user@carswaddle.com", password: password) { json, token, error in
            XCTAssert(error != nil, "Should have not logged in")
            XCTAssert(token == nil, "Should have not logged in")
            XCTAssert(json?["mechanic"] == nil, "Should have mechanic")
            XCTAssert(json?["user"] == nil, "Should have user")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testMechanicLogin() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.mechanicLogin(email: "user@carswaddle.com", password: password) { json, token, error in
            XCTAssert(token != nil, "Should have logged in")
            XCTAssert(json?["mechanic"] != nil, "Should have mechanic")
            XCTAssert(json?["user"] != nil, "Should have user")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testMechanicLoginIncorrectPassword() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.mechanicLogin(email: "k@k.com", password: "some incorrect password") { json, token, error in
            XCTAssert(token == nil, "Should not have logged in incorrect pass")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testMechanicLoginIncorrectEmail() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        authService.mechanicLogin(email: "kasdofi37@kasdfopi7.com", password: password) { json, token, error in
            XCTAssert(token == nil, "Should not have logged in incorrect email")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestUpdatePassword() {
        let exp = expectation(description: "\(#function)\(#line)")
//        authService.requestUpdatePassword(email: "kyle@carswaddle.com") { json, error in
        authService.requestUpdatePassword(email: "kyle@carswaddle.com", app: .carSwaddle) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testSetNewPassword() {
        let exp = expectation(description: "\(#function)\(#line)")
        authService.setNewPassword(newPassword: "thatone", token: "d8ec15f0-7dee-11e9-b887-73c97506c8ad") { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    /// Keep this here, but only uncomment if you want to create a new user
//    func testMechanicSignUp() {
//        let exp = expectation(description: "\(#function)\(#line)")
//
////        let newEmail = UUID().uuidString
//        let newEmail = "k"
//        authService.mechanicSignUp(email: newEmail + "@k.com", password: password) { json, token, error in
//            XCTAssert(token != nil, "Should have logged in")
//            XCTAssert(json?["mechanic"] != nil, "Should have mechanic")
//            XCTAssert(json?["user"] != nil, "Should have user")
//            exp.fulfill()
//        }
//
//        waitForExpectations(timeout: 40, handler: nil)
//    }

}

class LogoutTests: CarSwaddleLoginTestCase {
    
    private let authService = AuthService(serviceRequest: serviceRequest)
    
    func testLogout() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        //        authService.mechanicLogin(email: "kasdofi37@kasdfopi7.com", password: password) { json, token, error in
//        authService.login(email: "user@carswaddle.com", password: "password") { json, token, error in
//            XCTAssert(token != nil, "Token nil")authService.logout(deviceToken: "some string") { error in
                //            XCTAssert(token == nil, "Should not have logged in incorrect email")
        authService.logout(deviceToken: "some token") { error in
                XCTAssert(error == nil, "Should not have error")
                exp.fulfill()
            }
//        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
