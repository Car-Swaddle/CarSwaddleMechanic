//
//  AuthorityTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 6/19/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


import XCTest
@testable import CarSwaddleData
import CoreData
import Store


class AuthorityTests: LoginTestCase {
    
    let authorityNetwork = AuthorityNetwork(serviceRequest: serviceRequest)
    
    func testGetAuthorities() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.authorityNetwork.getAuthorities(limit: 30, offset: 0, in: privateContext) { authorityIDs, error in
                XCTAssert(authorityIDs.count > 0, "Should have reviews")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAuthorityRequests() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.authorityNetwork.getAuthorityRequests(limit: 30, offset: 0, pending: false, in: privateContext) { authorityRequestIDs, error in
                XCTAssert(authorityRequestIDs.count > 0, "Should have reviews")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateAuthorityRequest() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            let uuid = UUID().uuidString
            self.authorityNetwork.createAuthorityRequest(authority: "someAuthority" + uuid, in: privateContext) { authorityRequestID, error in
                XCTAssert(authorityRequestID != nil, "Should have reviews")
                privateContext.perform {
                    if let authorityRequestID = authorityRequestID {
                        let authorityRequest = privateContext.object(with: authorityRequestID) as? AuthorityRequest
                        XCTAssert(authorityRequest != nil, "Should not return secretID on creation")
                        XCTAssert(authorityRequest?.secretID == nil, "Should not return secretID on creation: \(String(describing: authorityRequest?.secretID))")
                    } else {
                        XCTAssert(false, "Must have authority request id")
                    }
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRejectAuthority() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            let secretID = "a86df8d1-9310-11e9-95ca-1f237b111990"
            self.authorityNetwork.rejectAuthorityRequest(secretID: secretID, in: privateContext) { authorityConfirmationID, error in
                XCTAssert(authorityConfirmationID != nil, "Should have reviews")
                if let id = authorityConfirmationID {
                    let authorityConfirmation = privateContext.object(with: id) as? AuthorityConfirmation
                    XCTAssert(authorityConfirmation?.status == .rejected, "Should have rejected, got: \(String(describing: authorityConfirmation?.status))")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testApproveAuthority() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            let secretID = "f79815d1-9310-11e9-95ca-1f237b111990"
            self.authorityNetwork.approveAuthorityRequest(secretID: secretID, in: privateContext) { authorityConfirmationID, error in
                XCTAssert(authorityConfirmationID != nil, "Should have reviews")
                if let id = authorityConfirmationID {
                    let authorityConfirmation = privateContext.object(with: id) as? AuthorityConfirmation
                    XCTAssert(authorityConfirmation?.status == .approved, "Should have approved, got: \(String(describing: authorityConfirmation?.status))")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
