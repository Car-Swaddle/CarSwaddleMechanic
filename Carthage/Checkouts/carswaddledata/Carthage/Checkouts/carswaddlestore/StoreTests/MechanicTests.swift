//
//  MechanicTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 12/5/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import CoreData
@testable import Store

class MechanicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? store.destroyAllData()
    }
    
    func testMechanicJSON() {
        let json = mechanicJSONWithUser
        
        let context = store.mainContext
        let mechanic = Mechanic.fetchOrCreate(json: json, context: context)
        context.persist()
        
        XCTAssert(mechanic != nil, "Should have user")
        XCTAssert(mechanic?.user != nil, "Should have mechanic")
    }
    
}

let mechanicJSONWithUser: JSONObject = [
    "id": mechanicID,
    "isActive": true,
    "user": userJSON
]
