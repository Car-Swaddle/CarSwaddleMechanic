//
//  AvailabilityTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

private let defaultDuration: Double = 60 * 60

class AvailabilityTests: CarSwaddleLoginTestCase {
    
    private let availabilityService = AvailabilityService(serviceRequest: serviceRequest)
    private let authService = AuthService(serviceRequest: serviceRequest)
    
    private var templatesJSON: [JSONObject] = []
    
    private func updateTemplates() {
        let templates = createTemplates()
        
        var json: [JSONObject] = []
        for template in templates {
            json.append(template.json)
        }
        templatesJSON = json
    }
    
    private var weekDays: [Int] = [0,1,2,3,4,5,6]
    private var hourOfDay: [Int] = [9,10,11,12,13,14,15,16,17,18]
    
    private func createTemplates() -> [Template] {
        var templates: [Template] = []
        for weekDay in weekDays {
            for hour in hourOfDay {
                let template = Template(startTime: Int64(hour * 3600), duration: defaultDuration, weekDay: weekDay)
                templates.append(template)
            }
        }
        return templates
    }
    
    override func setUp() {
        super.setUp()
        updateTemplates()
    }
    
    func testPostAvailability() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let templateCount = templatesJSON.count
        availabilityService.postAvailability(jsonArray: templatesJSON) { json, error in
            XCTAssert(json != nil, "Should have gotten json")
            XCTAssert(json?.count == templateCount, "Should have gotten \(templateCount) templates")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAvailability() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        availabilityService.getAvailability { json, error in
            XCTAssert(json != nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetAvailabilityWithMechanicID() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        availabilityService.getAvailability(ofMechanicWithID: "5c00fe80-e702-11e8-9a16-6dd8a1b37c0f") { json, error in
            XCTAssert(json != nil, "Should have gotten json")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}

struct Template {
    let startTime: Int64
    let duration: Double
    let weekDay: Int
    
    var json: JSONObject {
        return ["startTime": startTime, "duration": duration, "weekDay": weekDay]
    }
    
}
