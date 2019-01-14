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
    
    func testDestroy() {
        
        let identifier = "qwertyuiasdfghjk-1234567sdfghjk-nbvcxzasdf"
        
        let c = store.mainContext
        
        let user = User.fetch(with: identifier, in: c) ?? User(context: c)
        user.identifier = identifier
        
        c.persist()
        
        let fetchedUser = User.fetch(with: identifier, in: c)
        
        XCTAssert(fetchedUser != nil, "User should exist, test not valid")
        
        do {
            try store.destroyAllData()
        } catch {
            XCTAssert(false, "Couldn't delete all data on store, \(error)")
            return
        }
        
        let secondFetchedUser = User.fetch(with: identifier, in: store.mainContext)
        XCTAssert(secondFetchedUser == nil, "Should not have gotten any user")
        
        let newUser = User(context: store.mainContext)
        newUser.identifier = identifier
        
        store.mainContext.persist()
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { privateContext in
            let fetchedExist = User.fetch(with: identifier, in: privateContext)
            XCTAssert(fetchedExist != nil, "Should not have gotten any user")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
        
        print("before")
        store.privateContextAndWait { privateContext in
            let fetchedExist = User.fetch(with: identifier, in: privateContext)
            XCTAssert(fetchedExist != nil, "Should not have gotten any user")
            print("inside")
        }
        print("after")
    }
    
}
