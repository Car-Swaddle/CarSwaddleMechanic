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
        let region = Region(json: regionJSON, in: context)
        XCTAssert(region != nil, "Must have region from: \(regionJSON)")
    }
    
    func testSetRegion() {
        let context = store.mainContext
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = "someid"
        
        let region = Region(json: regionJSON, in: context)
        mechanic.serviceRegion = region
        
        store.mainContext.persist()
    }
    
}

private let regionJSON: [String: Any] = [
    "latitude": CGFloat(12.0),
    "longitude": CGFloat(-19.0),
    "radius": Double(203.0),
    "id": "234567-5678765434567-98734"
]
