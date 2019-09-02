//
//  VehicleTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 11/15/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store

class VehicleTests: LoginTestCase {
    
    let vehicleNetwork = VehicleNetwork(serviceRequest: serviceRequest)
    
    func testCreateVehicle() {
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        let name = "Dat name"
        let plate = "125 GUE"
        
        store.privateContext { context in
            self.vehicleNetwork.createVehicle(name: name, vin: plate, in: context) { objectID, error in
                store.mainContext { mCtx in
                    guard let objectID = objectID, let vehicle = mCtx.object(with: objectID) as? Vehicle else {
                        XCTAssert(false, "Didn't get vehicle when fetching")
                        return
                    }
                    
                    XCTAssert(vehicle.name == name, "Should have gotten right name")
                    XCTAssert(vehicle.licensePlate == plate, "Should have gotten right plate")
                    XCTAssert(vehicle.vin == nil, "Should have gotten right vin")
                    
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testRequestVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        
        let name = "Dat name"
        let plate = "125 GUE"
        let state = "Utah"
        
        store.privateContext { context in
            self.vehicleNetwork.createVehicle(name: name, licensePlate: plate, state: state, in: context) { objectID, error in
                guard let oID = objectID, let v = context.object(with: oID) as? Vehicle else {
                    XCTAssert(false, "Didn't get object")
                    return
                }
                self.vehicleNetwork.requestVehicle(vehicleID: v.identifier, in: context) { objectID, error in
                    guard let objectID = objectID, let vehicle = context.object(with: objectID) as? Vehicle else {
                        XCTAssert(false, "Didn't get object")
                        return
                    }
                    XCTAssert(vehicle.name == name, "Should have gotten name")
                    XCTAssert(vehicle.licensePlate == plate, "Should have gotten name")
                    XCTAssert(vehicle.state == state, "Should have gotten name")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testRequestVehicles() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { context in
            self.vehicleNetwork.requestVehicles(in: context) { objectIDs, error in
                guard let objectID = objectIDs.last, let vehicle = context.object(with: objectID) as? Vehicle else {
                    XCTAssert(false, "Didn't get object")
                    return
                }
                XCTAssert(vehicle.name.isEmpty == false, "Should have gotten name")
                XCTAssert(vehicle.licensePlate != nil || vehicle.vin != nil, "Should have gotten licensePlate")
                XCTAssert(vehicle.state != nil || vehicle.state != nil, "Should have gotten state")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let name = "Dat name"
        let plate = "125 GUE"
        let state = "Utah"
        
        store.privateContext { context in
            self.vehicleNetwork.createVehicle(name: name, licensePlate: plate, state: state, in: context) { objectID, error in
                guard let oID = objectID, let v = context.object(with: oID) as? Vehicle else {
                    XCTAssert(false, "Didn't get object")
                    return
                }
                self.vehicleNetwork.deleteVehicle(vehicleID: v.identifier, in: context) { error in
                    XCTAssert(error == nil, "Should not have gotten an error")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteNoVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { context in
            self.vehicleNetwork.deleteVehicle(vehicleID: "", in: context) { error in
                XCTAssert(error != nil, "Should not have gotten an error")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let name = "Dat name"
        let plate = "125 GUE"
        let state = "Utah"
        
        store.privateContext { context in
            self.vehicleNetwork.createVehicle(name: name, licensePlate: plate, state: state, in: context) { objectID, error in
                guard let oID = objectID, let v = context.object(with: oID) as? Vehicle else {
                    XCTAssert(false, "Didn't get object")
                    return
                }
                let newName = "New name"
                let newPlate = "dat new plate"
                let newState = "North Carolina"
                self.vehicleNetwork.updateVehicle(vehicleID: v.identifier, name: newName, licensePlate: newPlate, state: state, vin: nil, in: context) { objectID, error in
                    guard let objectID = objectID, let vehicle = context.object(with: objectID) as? Vehicle else {
                        XCTAssert(false, "Didn't get object")
                        return
                    }
                    XCTAssert(vehicle.name == newName, "Should have new name")
                    XCTAssert(vehicle.licensePlate == newPlate, "Should have new name")
                    XCTAssert(vehicle.vin == nil, "Vin should be nil")
                    XCTAssert(vehicle.state == newState, "Vin should be nil")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}



