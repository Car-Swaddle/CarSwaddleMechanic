//
//  StoreTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 9/13/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import CoreData
@testable import Store

let store = Store(bundle: Bundle(identifier: "CS.Store")!, storeName: "CarSwaddleStore", containerName: "StoreContainer")

class StoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetupStore() {
        let store = Store(bundle: Bundle(identifier: "CS.Store")!, storeName: "CarSwaddleStore", containerName: "StoreContainer")
        store.mainContext.persist()
    }
    
    func testInsertTemplateTimespan() {
        
        let mechanic = Mechanic(context: store.mainContext)
        mechanic.identifier = "someid"
        
        let template = TemplateTimeSpan(context: store.mainContext)
        template.weekday = .wednesday
        template.duration = 60*60
        template.mechanic = mechanic
        template.startTime = 0
        store.mainContext.persist()
        
        _ = template.weekday
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
