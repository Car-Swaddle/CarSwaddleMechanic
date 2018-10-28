//
//  RegionServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class RegionServiceTests: CarSwaddleLoginTestCase {
    
    let regionService = RegionService()
    
    func testPostRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        let radius: Double = 200
        let latitude: CGFloat = 11.909
        let longitude: CGFloat = -11.8978
        regionService.postRegion(latitude: latitude, longitude: longitude, radius: radius) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten back json")
            if let regionJSON = json?["region"] as? JSONObject {
                XCTAssert(regionJSON["radius"] as? Double == radius, "Should have gotten back json")
                XCTAssert(regionJSON["latitude"] as? CGFloat == latitude, "Should have gotten back json")
                XCTAssert(regionJSON["longitude"] as? CGFloat == longitude, "Should have gotten back json")
            } else {
                XCTAssert(false, "Should have region json")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
