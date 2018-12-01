//
//  RegionServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

let testMechanicRadius: Double = 5000.0
let testMechanicLatitude: Double = 40.38754862123388
let testMechanicLongitude: Double = -111.82703949226095

class RegionServiceTests: CarSwaddleLoginTestCase {
    
    let regionService = RegionService(serviceRequest: serviceRequest)
    
    func testPostRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        regionService.postRegion(latitude: testMechanicLatitude, longitude: testMechanicLongitude, radius: testMechanicRadius) { json, error in
            XCTAssert(json != nil && error == nil, "Should have gotten back json")
            if let regionJSON = json?["region"] as? JSONObject {
                XCTAssert(regionJSON["radius"] as? Double == testMechanicRadius, "Should have gotten back json")
                XCTAssert(regionJSON["latitude"] as? Double == testMechanicLatitude, "Should have gotten back json")
                XCTAssert(regionJSON["longitude"] as? Double == testMechanicLongitude, "Should have gotten back json")
            } else {
                XCTAssert(false, "Should have region json")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        regionService.postRegion(latitude: testMechanicLatitude, longitude: testMechanicLongitude, radius: testMechanicRadius) { postJSON, error in
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
