//
//  UserTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 12/5/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import CoreData
@testable import Store

class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? store.destroyAllData()
    }
    
    func testUserJSON() {
        let json = userJSONWithMechanic
        
        let context = store.mainContext
        
        let user = User.fetchOrCreate(json: json, context: context)
        context.persist()
        
        XCTAssert(user != nil, "Should have user")
        XCTAssert(user?.mechanic != nil, "Should have mechanic")
        XCTAssert(user?.isEmailVerified == true, "Should have mechanic")
    }
    
}


let userJSONWithMechanic: [String: Any] = [
    "firstName": "Rupert",
    "lastName": "Rupertarious",
    "phoneNumber": "928-273-8726",
    "id": userID,
    "mechanic": mechanicJSON,
    "isEmailVerified": true
]
