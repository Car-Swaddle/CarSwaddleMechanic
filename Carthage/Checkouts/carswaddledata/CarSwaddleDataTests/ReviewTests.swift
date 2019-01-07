//
//  ReviewTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store


class ReviewTests: LoginTestCase {
    
    let reviewNetwork = ReviewNetwork(serviceRequest: serviceRequest)
    
    func testGetReviewsByCurrentUser() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.reviewNetwork.getReviewsByCurrentUser(in: privateContext) { reviewIDs, error in
                XCTAssert(reviewIDs.count > 0, "Should have reviews")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetReviewsForMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
//            self.reviewNetwork.getReviewsByCurrentUser(in: privateContext) { reviewIDs, error in
            self.reviewNetwork.getReviews(forMechanicWithID: "ce8b0070-0e41-11e9-834e-458588e04d18", in: privateContext) { reviewIDs, error in
                XCTAssert(reviewIDs.count > 0, "Should have reviews")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
