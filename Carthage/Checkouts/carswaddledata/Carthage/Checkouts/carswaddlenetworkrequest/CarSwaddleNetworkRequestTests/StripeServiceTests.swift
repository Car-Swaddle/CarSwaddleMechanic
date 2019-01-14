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
    
    func testStripeBalance() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        stripeService.getBalance { json, error in
            XCTAssert(json != nil, "Json is nil")
            
            if let available = json?["available"] as? [JSONObject], let first = available.first {
                XCTAssert((first["amount"] as? Int) != nil, "Should have available")
                XCTAssert((first["currency"] as? String) != nil, "Should have available")
            } else {
                XCTAssert(false, "Should have availabel")
            }
            if let reserved = json?["connect_reserved"] as? [JSONObject], let first = reserved.first {
                XCTAssert((first["amount"] as? Int) != nil, "Should have available")
                XCTAssert((first["currency"] as? String) != nil, "Should have available")
            } else {
                XCTAssert(false, "Should have connect_reserved")
            }
            if let pending = json?["pending"] as? [JSONObject], let first = pending.first {
                XCTAssert((first["amount"] as? Int) != nil, "Should have available")
                XCTAssert((first["currency"] as? String) != nil, "Should have available")
            } else {
                XCTAssert(false, "Should have pending")
            }
            XCTAssert(error == nil, "Got error: \(error?.localizedDescription ?? "")")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetTransactions() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        stripeService.getTransactions { json, error in
            XCTAssert(json != nil, "Json is nil")
            
            if let data = json?["data"] as? [JSONObject], let first = data.first {
                XCTAssert((first["id"] as? String) != nil, "Should have available")
                XCTAssert((first["amount"] as? Int) != nil, "Should have available")
                XCTAssert((first["available_on"] as? Int) != nil, "Should have available")
                XCTAssert((first["currency"] as? String) != nil, "Should have available")
//                XCTAssert((first["description"] as? String) != nil, "Should have available")
//                XCTAssert((first["exchange_rate"] as? String) != nil, "Should have available")
                XCTAssert((first["fee"] as? Int) != nil, "Should have available")
                XCTAssert((first["fee_details"] as? [Any]) != nil, "Should have available")
                XCTAssert((first["net"] as? Int) != nil, "Should have available")
                XCTAssert((first["source"] as? String) != nil, "Should have available")
                XCTAssert((first["status"] as? String) != nil, "Should have available")
                XCTAssert((first["type"] as? String) != nil, "Should have available")
            } else {
                XCTAssert(false, "Should have `data`.first")
            }
            
            XCTAssert((json?["has_more"] as? Bool) != nil, "Should have `hasMore`")
            XCTAssert(error == nil, "Got error: \(error?.localizedDescription ?? "")")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetPayouts() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        stripeService.getPayouts { json, error in
            XCTAssert(json != nil, "Json is nil")
            
            if let data = json?["data"] as? [JSONObject], let first = data.first {
                XCTAssert((first["id"] as? String) != nil, "Should have available")
                XCTAssert((first["amount"] as? Int) != nil, "Should have available")
                XCTAssert((first["arrival_date"] as? Int) != nil, "Should have available")
                XCTAssert((first["currency"] as? String) != nil, "Should have available")
                XCTAssert((first["balance_transaction"] as? String) != nil, "Should have available")
                XCTAssert((first["created"] as? Int) != nil, "Should have available")
//                XCTAssert((first["description"] as? String) != nil, "Should have available")
//                XCTAssert((first["destination"] as? String) != nil, "Should have available")
//                XCTAssert((first["failure_code"] as? Int) != nil, "Should have available")
//                XCTAssert((first["failure_message"] as? String) != nil, "Should have available")
//                XCTAssert((first["statement_descriptor"] as? String) != nil, "Should have available")
                XCTAssert((first["status"] as? String) != nil, "Should have available")
                XCTAssert((first["type"] as? String) != nil, "Should have available")
                XCTAssert((first["method"] as? String) != nil, "Should have available")
                
            } else {
                XCTAssert(false, "Should have `data`.first")
            }
            
            XCTAssert((json?["has_more"] as? Bool) != nil, "Should have `hasMore`")
            XCTAssert(error == nil, "Got error: \(error?.localizedDescription ?? "")")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
