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

class StoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let store = Store(bundle: Bundle(identifier: "CS.Store")!, storeName: "CarSwaddleStore", containerName: "StoreContainer")
        
        store.mainContext.persist()
    
//        let bundle = Bundle(for: Store.self)
//        let d = bundle.url(forResource: "NewModel", withExtension: "momd")!
//
//        let model = NSManagedObjectModel(contentsOf: d)!
//
//        let container = NSPersistentContainer(name: "some name", managedObjectModel: model)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
