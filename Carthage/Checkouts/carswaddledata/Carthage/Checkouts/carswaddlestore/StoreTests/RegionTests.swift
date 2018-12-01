//
//  RegionTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 10/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store


class RegionTests: XCTestCase {
    
    func testCreateRegion() {
        let context = store.mainContext
        let region = Region(json: regionJSON, context: context)
        XCTAssert(region != nil, "Must have region from: \(regionJSON)")
    }
    
    func testSetRegion() {
        let context = store.mainContext
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = "someid"
        
        let region = Region(json: regionJSON, context: context)
        mechanic.serviceRegion = region
        
        XCTAssert(region != nil, "Region should exist")
        
        store.mainContext.persist()
    }
    
    func testSetRegionWeirdJSON() {
        let context = store.mainContext
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = "someid"
        
        let region = Region(json: regionWeirdJSON, context: context)
        mechanic.serviceRegion = region
        
        XCTAssert(region != nil, "Region should exist")
        
        store.mainContext.persist()
    }
    
}


private let regionWeirdJSON: [String: Any] = ["longitude": -111.827039492261, "createdAt": "2018-11-13T07:14:14.453Z", "firstName": "Rupert", "radius": 360, "isActive": 1, "updatedAt": "2018-11-13T07:14:14.460Z", "distance": 0, "lastName": "Rolph", "latitude": 40.38754862123388, "id": "5c00fe80-e702-11e8-9a16-6dd8a1b37c0f", "userID": "2e8ec720-e702-11e8-9a16-6dd8a1b37c0f", "phoneNumber": "801-111-1111", "regionID": "28114f80-e716-11e8-bfed-87ccb8fe8373"]

private let regionJSON: [String: Any] = [
    "latitude": Double(12.0),
    "longitude": Double(-19.0),
    "radius": Double(203.0),
    "id": "234567-5678765434567-98734"
]
