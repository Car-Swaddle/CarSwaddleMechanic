//
//  MechanicTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import Store
@testable import CarSwaddleData

let atlanticLatitude: Double = 28.237381
let atlanticLongitude: Double = -47.420196

class MechanicTests: LoginTestCase {
    
    let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    func testGetNearestMechanicsClose() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: testMechanicLatitude, longitude: testMechanicLongitude, maxDistance: 1000, in: context) { mechanicIDs, error in
                
                XCTAssert(mechanicIDs.count > 0, "Should have 1 mechanic, got: \(mechanicIDs.count)")
                
                for mechanicID in mechanicIDs {
                    let mechanic = context.object(with: mechanicID) as? Mechanic
                    XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                    XCTAssert(mechanic?.user != nil, "User is nil, should have gotten a user")
                    XCTAssert(mechanic?.serviceRegion != nil, "serviceRegion is nil, should have gotten a serviceRegion")
                }
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateCurrentMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let isActive = true
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: isActive, token: "SomeKey", in: context) { mechanicID, error in
                guard let mechanicID = mechanicID else {
                    XCTAssert(false, "Should have mechanicID")
                    return
                }
                
                let mechanic = context.object(with: mechanicID) as? Mechanic
                XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                XCTAssert(mechanic?.isActive == isActive, "Should be isActive. is \(mechanic!.isActive) should be \(isActive)")
//                XCTAssert(mechanic?.user != nil, "User is nil, should have gotten a user")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetCurrentMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getCurrentMechanic(in: context) { mechanicID, error in
                guard let mechanicID = mechanicID else {
                    XCTAssert(false, "Should have mechanicID")
                    return
                }
                
                let mechanic = context.object(with: mechanicID) as? Mechanic
                XCTAssert(mechanic != nil, "Mechanic is nil, should have gotten a mechanic")
                XCTAssert(mechanic?.isActive != nil, "Should have isActive.)")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetNearestMechanicsAtlantic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 5000, in: context) { mechanicIDs, error in
                XCTAssert(mechanicIDs.count == 0, "Should have 0 mechanic, got: \(mechanicIDs.count)")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testPerformanceGetNearestMechanicsAtlantic() {
        measure {
            let exp = expectation(description: "\(#function)\(#line)")
            
            store.privateContext { [weak self] context in
                self?.mechanicNetwork.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 5000, in: context) { mechanicIDs, error in
                    exp.fulfill()
                }
            }
            
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
}
