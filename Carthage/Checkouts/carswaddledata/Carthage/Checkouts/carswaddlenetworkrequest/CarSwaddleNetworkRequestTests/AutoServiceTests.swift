//
//  AutoServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest


class AutoServiceTests: CarSwaddleLoginTestCase {
    
    
    private let autoServiceID = "09d3c2c0-3084-11e9-b606-eff43c501111"
    
    private let autoServiceService = AutoServiceService(serviceRequest: serviceRequest)
    
    private var startDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2017, month: 11, day: 20, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    private var endDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2020, month: 11, day: 25, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    func testCreateAutoService() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON, sourceID: "") { json, error in
            
            XCTAssert(json != nil, "Should have json")
            XCTAssert(error == nil, "Should not have error")
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateAutoServiceLocationID() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON, sourceID: "") { json, error in
            
            var createJSON = autoServiceJSONLocationID
            createJSON["locationID"] = (json!["location"] as! JSONObject)["id"] as! String
            
            self.autoServiceService.createAutoService(autoServiceJSON: createJSON, sourceID: "") { json, error in
                
                XCTAssert(json != nil, "Should have json")
                XCTAssert(error == nil, "Should not have error")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testCreateAutoServicePerformance() {
        self.measure {
            let exp = expectation(description: "\(#function)\(#line)")
            autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON, sourceID: "") { json, error in
                
                XCTAssert(json != nil, "Should have json")
                XCTAssert(error == nil, "Should not have error")
                
                exp.fulfill()
            }
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
    func testGetAutoServiceDetails() {
        let exp = expectation(description: "\(#function)\(#line)")
        autoServiceService.getAutoServiceDetails(autoServiceID: autoServiceID) { json, error in
            XCTAssert(json != nil, "Should have json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServices() {
        let exp = expectation(description: "\(#function)\(#line)")
        autoServiceService.getAutoServices(mechanicID: currentMechanicID, startDate: startDate, endDate: endDate, filterStatus: []) { jsonArray, error in
            guard let jsonArray = jsonArray else {
                XCTAssert(false, "Should have json")
                exp.fulfill()
                return
            }
            XCTAssert(jsonArray.count > 0, "Should have auto service")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAutoServicesLimit() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.getAutoServices(limit: 10, offset: 0, sortStatus: ["inProgress", "scheduled", "completed"]) { jsonArray, error in
            guard let jsonArray = jsonArray else {
                XCTAssert(false, "Should have json")
                exp.fulfill()
                return
            }
            XCTAssert(jsonArray.count > 0, "Should have auto service")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    
    func testUpdateAutoService() {
        let exp = expectation(description: "\(#function)\(#line)")
        autoServiceService.createAutoService(autoServiceJSON: newAutoServiceJSON, sourceID: "") { newJSON, error in
            self.autoServiceService.updateAutoService(autoServiceID: newJSON!["id"] as! String, json: updateAutoServiceJSON) { updatedJSON, error in
                guard let updatedJSON = updatedJSON else {
                    XCTAssert(false, "Should have json")
                    exp.fulfill()
                    return
                }
                XCTAssert(updatedJSON["status"] as? String == updateAutoServiceJSON["status"] as? String, "Should have changed value")
                //                XCTAssert((updatedJSON["location"] as? JSONObject) == updateAutoServiceJSON["location"] as? JSONObject, "Should have changed value")
                XCTAssert((updatedJSON["vehicle"] as? JSONObject)?["id"] as? String == updateAutoServiceJSON["vehicleID"] as? String, "Should have changed value")
                XCTAssert(updatedJSON["notes"] as? String == updateAutoServiceJSON["notes"] as? String, "Should have changed value")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }

}


private let updateAutoServiceJSON: JSONObject = [
    "status": "inProgress",
    "scheduledDate": "2019-01-22 16:00:00 +0000",
    "location": [
        "longitude": -111.83011200000003,
        "latitude": 40.28097000000002
    ],
    "vehicleID": edgeVehicleID,
    "notes": "After %^&* EDGE"
//    "mechanicID": ""
]

private let edgeVehicleID = "b1fa6010-febd-11e8-9811-059afcb3ba5e"
private let explorerVehicleID = "ae222ef0-febd-11e8-9811-059afcb3ba5e"

private let mechanicID = "8ba0ded0-febd-11e8-9811-059afcb3ba5e"
private let userID = "6d6a30b0-febd-11e8-9811-059afcb3ba5e"
private let vehicleID = explorerVehicleID

private let newAutoServiceJSON: JSONObject = [
    "vehicleID": vehicleID,
    "location": [
        "longitude": -111.83011800000003,
        "latitude": 40.38097000000002
    ],
    "serviceEntities": [
        [
            "specificService": [
                "oilType": "SYNTHETIC"
            ],
            "entityType": "OIL_CHANGE"
        ]
    ],
    "status": "scheduled",
    "mechanicID": mechanicID,
    "scheduledDate": "2018-11-22 16:00:00 +0000",
    "notes": "Before update %^&* EXPLORER"
]

private let autoServiceJSON: JSONObject = [
    "vehicleID": vehicleID,
    "location": [
        "longitude": -111.83011800000003,
        "latitude": 40.38097000000002
    ],
    "serviceEntities": [
        [
            "specificService": [
                "oilType": "SYNTHETIC"
            ],
            "entityType": "OIL_CHANGE"
        ]
    ],
    "status": "scheduled",
    "mechanicID": mechanicID,
    "scheduledDate": "2018-11-22 16:00:00 +0000"
]

private let autoServiceJSONLocationID: JSONObject = [
    "vehicleID": vehicleID,
    "locationID": "21576090-fd22-11e8-b447-9368f8ffb290",
    "serviceEntities": [
        [
            "specificService": [
                "oilType": "SYNTHETIC"
            ],
            "entityType": "OIL_CHANGE"
        ]
    ],
    "status": "scheduled",
    "mechanicID": mechanicID,
    "scheduledDate": "2018-11-22 16:00:00 +0000"
]
