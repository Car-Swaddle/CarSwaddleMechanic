//
//  CarSwaddleDataTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store

let store = Store(bundle: Bundle(identifier: "CS.Store")!, storeName: "CarSwaddleStore", containerName: "StoreContainer")

class CarSwaddleDataTests: XCTestCase {

//    override func setUp() {
//        let exp = expectation(description: "The ex")
//        store.privateContext { context in
//            Auth().login(email: "k@k.com", password: "password", context: context) { error in
//                print("in")
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 40, handler: nil)
//    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
