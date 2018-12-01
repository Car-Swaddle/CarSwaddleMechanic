//
//  MechanicServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class MechanicServiceTests: CarSwaddleLoginTestCase {
    
    private let service = MechanicService(serviceRequest: serviceRequest)
    
    private let closeLatitude: Double = 40.38754862123388
    private let closeLongitude: Double = -111.82703949226095
    
    private let atlanticLatitude: Double = 28.237381
    private let atlanticLongitude: Double = -47.420196
    
    func testNearestMechanics() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getNearestMechanics(limit: 10, latitude: closeLatitude, longitude: closeLongitude, maxDistance: 1000) { jsonArray, error in
            
            if let jsonArray = jsonArray {
                XCTAssert(jsonArray.count > 0, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testNearestMechanicsAtlantic() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 1000) { jsonArray, error in
            
            if let jsonArray = jsonArray {
                XCTAssert(jsonArray.count == 0, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testPerformanceNearestMechanics() {
        
        measure {
            let exp = expectation(description: "\(#function)\(#line)")
            service.getNearestMechanics(limit: 10, latitude: closeLatitude, longitude: closeLongitude, maxDistance: 1000) { jsonArray, error in
                exp.fulfill()
            }
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
}
