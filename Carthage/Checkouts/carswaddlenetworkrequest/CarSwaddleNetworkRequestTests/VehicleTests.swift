//
//  VehicleTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/15/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class VehicleTests: CarSwaddleLoginTestCase {
    
    private let vehicleService = VehicleService(serviceRequest: serviceRequest)
    
    func testCreateVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        let name = "Edge"
        let plate = "128 DHQ"
        let state = "Utah"
        vehicleService.postVehicle(name: name, licensePlate: plate, state: state) { vehicleJSON, error in
            XCTAssert(vehicleJSON != nil, "Should have json")
            XCTAssert(vehicleJSON?["name"] as? String == name, "Should have name")
            XCTAssert(vehicleJSON?["licensePlate"] as? String == plate, "Should have licensePlate")
            XCTAssert(vehicleJSON?["state"] as? String == plate, "Should have licensePlate")
            XCTAssert(vehicleJSON?["id"] != nil, "Should have id")
            XCTAssert(vehicleJSON?["state"] as? String != state, "Should have state")
            
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        let name = "Edge !@#$%^&*("
        let plate = "128 DHQ $%^YHJKL"
        let state = "Dat state"
        vehicleService.postVehicle(name: "Different name", licensePlate: "nosht plate", state: state) { vehicleJSON, error in
            guard let vehicleID = vehicleJSON?["id"] as? String else {
                XCTAssert(false, "Coudln't create vehicle")
                return
            }
            self.vehicleService.putVehicle(vehicleID: vehicleID, name: name, licensePlate: plate, state: state, vin: nil) { vehicleJSON, error in
                XCTAssert(vehicleJSON != nil, "Should have json")
                XCTAssert(vehicleJSON?["name"] as? String == name, "Should have name")
                XCTAssert(vehicleJSON?["licensePlate"] as? String == plate, "Should have licensePlate")
                XCTAssert(vehicleJSON?["id"] != nil, "Should have id")
                XCTAssert(vehicleJSON?["state"] as? String != state, "Should have state")
                
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        vehicleService.postVehicle(name: "a name", licensePlate: "a plate", state: "state") { vehicleJSON, error in
            guard let vehicleID = vehicleJSON?["id"] as? String else {
                XCTAssert(false, "Coudln't create vehicle")
                return
            }
            self.vehicleService.deleteVehicle(vehicleID: vehicleID) { error in
                XCTAssert(error == nil, "Should have json")
                
                self.vehicleService.getVehicle(vehicleID: vehicleID) { gotVehicleJSON, error in
                    XCTAssert(gotVehicleJSON == nil, "Should have json")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteNonexistant() {
        let exp = expectation(description: "\(#function)\(#line)")
        self.vehicleService.deleteVehicle(vehicleID: "") { error in
            XCTAssert(error != nil, "Should have error")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetVehicles() {
        let exp = expectation(description: "\(#function)\(#line)")
        vehicleService.getVehicles { vehiclesJSON, error in
            XCTAssert(vehiclesJSON != nil, "Should have json")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetVehicle() {
        let exp = expectation(description: "\(#function)\(#line)")
        let name = "Edge"
        let plate = "128 DHQ"
        let state = "Utah"
        vehicleService.postVehicle(name: name, licensePlate: plate, state: state) { vehicleJSON, error in
            guard let vehicleID = vehicleJSON?["id"] as? String else {
                XCTAssert(false, "Coudln't create vehicle")
                return
            }
            self.vehicleService.getVehicle(vehicleID: vehicleID) { gotVehicleJSON, error in
                XCTAssert(vehicleJSON != nil, "Should have json")
                XCTAssert(vehicleJSON?["name"] as? String == name, "Should have name")
                XCTAssert(vehicleJSON?["licensePlate"] as? String == plate, "Should have licensePlate")
                XCTAssert(vehicleJSON?["id"] != nil, "Should have id")
                XCTAssert(vehicleJSON?["state"] as? String != state, "Should have state")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
