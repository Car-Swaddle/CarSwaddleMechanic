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
    
    private let autoServiceService = AutoServiceService(serviceRequest: serviceRequest)
    
    private var startDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2018, month: 11, day: 20, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    private var endDate: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 2018, month: 11, day: 25, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    func testCreateAutoService() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON) { json, error in
            
            XCTAssert(json != nil, "Should have json")
            XCTAssert(error == nil, "Should not have error")
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateAutoServiceLocationID() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON) { json, error in
            
            var createJSON = autoServiceJSONLocationID
            createJSON["locationID"] = (json!["location"] as! JSONObject)["id"] as! String
            
            self.autoServiceService.createAutoService(autoServiceJSON: createJSON) { json, error in
                
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
            autoServiceService.createAutoService(autoServiceJSON: autoServiceJSON) { json, error in
                
                XCTAssert(json != nil, "Should have json")
                XCTAssert(error == nil, "Should not have error")
                
                exp.fulfill()
            }
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
    func testGetAutoServices() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        autoServiceService.getAutoServices(mechanicID: "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb", startDate: startDate, endDate: endDate, status: ["inProgress", "scheduled", "completed"]) { jsonArray, error in
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

}


private let autoServiceJSON: JSONObject = [
    "vehicleID": "bbb8c060-eaa9-11e8-a56c-2953c4831dcb",
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
    "mechanicID": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb",
    "scheduledDate": "2018-11-22 16:00:00 +0000"
]

private let autoServiceJSONLocationID: JSONObject = [
    "vehicleID": "bbb8c060-eaa9-11e8-a56c-2953c4831dcb",
    "locationID": "3543f6e0-ec9c-11e8-8e07-7b80a5dfaf20",
    "serviceEntities": [
        [
            "specificService": [
                "oilType": "SYNTHETIC"
            ],
            "entityType": "OIL_CHANGE"
        ]
    ],
    "status": "scheduled",
    "mechanicID": "10aaf8a0-ea9f-11e8-a56c-2953c4831dcb",
    "scheduledDate": "2018-11-22 16:00:00 +0000"
]
