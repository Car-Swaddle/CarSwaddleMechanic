//
//  ReviewServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 1/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest


class ReviewServiceTests: CarSwaddleLoginTestCase {
    
    let reviewService = ReviewService(serviceRequest: serviceRequest)
    
    func testGetReviewForCurrentUser() {
        let exp = expectation(description: "\(#function)\(#line)")
        reviewService.getReviewsByCurrentUser { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten back json")
            XCTAssert(json?["reviewsGivenByCurrentUser"] as? [JSONObject] != nil, "Should have region json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetReviewForMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        reviewService.getReviews(forMechanicWithID: currentMechanicID) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten back json")
            XCTAssert(json?["reviewsGivenToMechanic"] as? [JSONObject] != nil, "Should have region json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRatingsReceived() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        reviewService.getAverageRatingForCurrentUser { json, error in
            XCTAssert(json?["rating"] as? CGFloat != nil, "Should have rating")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRatingsForMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        reviewService.getAverageRating(mechanicID: "ce8b0070-0e41-11e9-834e-458588e04d18") { json, error in
            XCTAssert(json?["rating"] as? CGFloat != nil, "Should have rating")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRatingsForEmptyMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        reviewService.getAverageRating(mechanicID: "") { json, error in
            XCTAssert(json?["rating"] != nil, "Should have rating")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRatingsForUser() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        reviewService.getAverageRating(userID: "00e80f70-0e58-11e9-97e3-23156c356f56") { json, error in
            XCTAssert(json?["rating"] != nil, "Should have rating")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
