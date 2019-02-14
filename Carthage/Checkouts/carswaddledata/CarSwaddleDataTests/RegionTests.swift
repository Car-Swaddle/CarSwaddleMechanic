//
//  RegionTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 10/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store

let testMechanicRadius: Double = 5000
let testMechanicLatitude: Double = 40.38754862123388
let testMechanicLongitude: Double = -111.82703949226095

class RegionTests: LoginTestCase {
    
    let regionNetwork = RegionNetwork(serviceRequest: serviceRequest)
    
    func testPostRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        regionNetwork.postRegion(latitude: testMechanicLatitude, longitude: testMechanicLongitude, radius: testMechanicRadius, in: context) { objectID, error in
            guard let objectID = objectID else {
                XCTAssert(false, "Should have object ID")
                exp.fulfill()
                return
            }
            context.performOnImportQueue {
                let region = context.object(with: objectID) as? Region
                XCTAssert(region != nil, "Should have region here")
                XCTAssert(region?.radius == testMechanicRadius, "Should have \(testMechanicRadius) got \(String(describing: region?.radius))")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetRegion() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        let latitude: Double = 11.3
        let longitude: Double = -89.37
        let radius: Double = 360
        regionNetwork.postRegion(latitude: latitude, longitude: longitude, radius: radius, in: context) { postObjectID, error in
            guard postObjectID != nil else {
                XCTAssert(false, "Should have object ID")
                exp.fulfill()
                return
            }
            context.performOnImportQueue {
                self.regionNetwork.getRegion(in: context) { objectID, error in
                    context.performOnImportQueue {
                        guard let objectID = objectID else {
                            XCTAssert(false, "Should have object ID")
                            exp.fulfill()
                            return
                        }
                        let region = context.object(with: objectID) as? Region
                        XCTAssert(region != nil, "Should have region here")
                        XCTAssert(region?.radius == radius, "Should have \(radius) got \(String(describing: region?.radius))")
                        exp.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
