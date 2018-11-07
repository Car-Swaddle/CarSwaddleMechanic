//
//  NSManagedObjectFetchableTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 11/2/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store

class NSManagedObjectFetchableTests: XCTestCase {
    
    func testFetchIDs() {
        let context = store.mainContext
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = "someid"
        
        context.persist()
        
        let objects = Mechanic.fetchObjects(with: [mechanic.objectID], in: context)
        
        XCTAssert(objects.count == 1, "Should have an object")
        
    }
    
}
