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
    
    func testExistingMechanicFetchOrCreateChanges() {
        let context = store.mainContext
        let oldMechanic = Mechanic.fetchOrCreate(json: ["id": mechanicID, "isActive": true], context: context)
        context.persist()
        
        let newMechanic = Mechanic.fetchOrCreate(json: ["id": mechanicID, "isActive": false], context: context)
        context.persist()
        
        
        
        XCTAssert(oldMechanic != nil, "Should have oldMech")
        XCTAssert(newMechanic != nil, "Should have newMech")
        XCTAssert(oldMechanic?.isActive == false, "Should be the latest changes")
    }
    
}

let mechanicJSONWithUser: JSONObject = [
    "id": mechanicID,
    "isActive": true,
    "user": userJSON,
    "createdAt": "2019-06-14T04:46:23.176Z",
]
