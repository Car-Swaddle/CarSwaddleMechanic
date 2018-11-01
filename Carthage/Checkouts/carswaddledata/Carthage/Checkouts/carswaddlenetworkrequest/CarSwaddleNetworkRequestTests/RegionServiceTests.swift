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
    
    let regionService = RegionService(serviceRequest: serviceRequest)
    
    func testPostRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        let radius: Double = 200
        let latitude: Double = 11.909
        let longitude: Double = -11.8978
        regionService.postRegion(latitude: latitude, longitude: longitude, radius: radius) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten back json")
            if let regionJSON = json?["region"] as? JSONObject {
                XCTAssert(regionJSON["radius"] as? Double == radius, "Should have gotten back json")
                XCTAssert(regionJSON["latitude"] as? Double == latitude, "Should have gotten back json")
                XCTAssert(regionJSON["longitude"] as? Double == longitude, "Should have gotten back json")
            } else {
                XCTAssert(false, "Should have region json")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let radius: Double = 200
        let latitude: Double = 11.909
        let longitude: Double = -11.8978
        regionService.postRegion(latitude: latitude, longitude: longitude, radius: radius) { postJSON, error in
            self.regionService.getRegion { json, error in
                XCTAssert(json != nil && error == nil, "Should have gotten back json")
                if let regionJSON = json {
                    XCTAssert(regionJSON["radius"] as? Double != nil, "Should have gotten back json")
                    XCTAssert(regionJSON["latitude"] as? Double != nil, "Should have gotten back json")
                    XCTAssert(regionJSON["longitude"] as? Double != nil, "Should have gotten back json")
                } else {
                    XCTAssert(false, "Should have region json")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
