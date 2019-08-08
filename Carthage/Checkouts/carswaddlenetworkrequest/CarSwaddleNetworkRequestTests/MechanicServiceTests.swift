//
//  MechanicServiceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 11/7/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest

class MechanicServiceTests: CarSwaddleLoginTestCase {
    
    private let service = MechanicService(serviceRequest: serviceRequest)
    private let stripeService = StripeService(serviceRequest: serviceRequest)
    
    private let closeLatitude: Double = 40.38754862123388
    private let closeLongitude: Double = -111.82703949226095
    
    private let atlanticLatitude: Double = 28.237381
    private let atlanticLongitude: Double = -47.420196
    
    private let externalAccountID: String = "btok_1DmcPxIh8ecz19vMMmHJ2462"
    
    private var dob: Date {
        let dateComponents = DateComponents(calendar: Calendar.current, timeZone: nil, year: 1990, month: 11, day: 20, hour: 0)
        return dateComponents.date ?? Date()
    }
    
    func testNearestMechanics() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getNearestMechanics(limit: 10, latitude: closeLatitude, longitude: closeLongitude, maxDistance: 1000) { jsonArray, error in
            
            if let jsonArray = jsonArray {
                XCTAssert(jsonArray.count > 0, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testNearestMechanicsAtlantic() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getNearestMechanics(limit: 10, latitude: atlanticLatitude, longitude: atlanticLongitude, maxDistance: 1000) { jsonArray, error in
            
            if let jsonArray = jsonArray {
                XCTAssert(jsonArray.count == 0, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        let token = "The token"
        let isActive = true
        service.updateCurrentMechanic(isActive: isActive, token: token, dateOfBirth: nil, addressJSON: nil, externalAccount: nil, socialSecurityNumberLast4: nil, personalIDNumber: nil) { json, error in
            if let json = json {
                XCTAssert(json["isActive"] as? Bool == isActive, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateMechanicDOBAndAddress() {
        let exp = expectation(description: "\(#function)\(#line)")
        let address = MechanicService.addressJSON(line1: "1541 N 1300 W St", line2: "Some line 2", postalCode: "84062", city: "American Fork", state: "Ut", country: "us")
        service.updateCurrentMechanic(isActive: nil, token: nil, dateOfBirth: dob, addressJSON: address, externalAccount: nil, socialSecurityNumberLast4: nil, personalIDNumber: nil) { json, error in
            if let json = json {
                if let dateString = json["dateOfBirth"] as? String,
                    let date = serverDateFormatter.date(from: dateString) {
                    XCTAssert(date == self.dob, "Should have correctJSON")
                }
                if let addressJSON = json["address"] as? JSONObject {
                    XCTAssert((addressJSON["line1"] as? String) == address["line1"] as? String, "Should have correctJSON")
                    XCTAssert((addressJSON["postalCode"] as? String) == address["postalCode"] as? String, "Should have correctJSON")
                    XCTAssert((addressJSON["city"] as? String) == address["city"] as? String, "Should have correctJSON")
                    XCTAssert((addressJSON["state"] as? String) == address["state"] as? String, "Should have correctJSON")
                }
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            self.stripeService.getVerification { json, error in
                guard let json = json,
                    let fieldsNeeded = json["fields_needed"] as? [String] else {
                        XCTAssert(false, "Should have json")
                        return
                }
                
                XCTAssert(fieldsNeeded.contains("legal_entity.address.city") == false, "Should have set needed field")
                XCTAssert(fieldsNeeded.contains("legal_entity.address.line1") == false, "Should have set needed field")
                XCTAssert(fieldsNeeded.contains("legal_entity.address.postal_code") == false, "Should have set needed field")
                XCTAssert(fieldsNeeded.contains("legal_entity.address.state") == false, "Should have set needed field")
                    
                XCTAssert(fieldsNeeded.contains("legal_entity.dob.day") == false, "Should have set needed field")
                XCTAssert(fieldsNeeded.contains("legal_entity.dob.month") == false, "Should have set needed field")
                XCTAssert(fieldsNeeded.contains("legal_entity.dob.year") == false, "Should have set needed field")
                
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateMechanicExternalAccount() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        service.updateCurrentMechanic(isActive: nil, token: nil, dateOfBirth: nil, addressJSON: nil, externalAccount: externalAccountID, socialSecurityNumberLast4: nil, personalIDNumber: nil) { json, error in
            self.stripeService.getVerification { json, error in
                guard let json = json,
                let fieldsNeeded = json["fields_needed"] as? [String] else {
                    XCTAssert(false, "Should have json")
                    return
                }
                
                XCTAssert(fieldsNeeded.contains("external_account") == false, "Should have set external account")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateMechanicSocialSecurityLast4() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        service.updateCurrentMechanic(isActive: nil, token: nil, dateOfBirth: nil, addressJSON: nil, externalAccount: nil, socialSecurityNumberLast4: "0000", personalIDNumber: nil) { json, error in
            self.stripeService.getVerification { json, error in
                guard let json = json,
                    let fieldsNeeded = json["fields_needed"] as? [String] else {
                        XCTAssert(false, "Should have json")
                        return
                }
                
                XCTAssert(fieldsNeeded.contains("legal_entity.ssn_last_4") == false, "Should have set external account")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testUpdateMechanicSocialSecurityNumber() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        service.updateCurrentMechanic(isActive: nil, token: nil, dateOfBirth: nil, addressJSON: nil, externalAccount: nil, socialSecurityNumberLast4: nil, personalIDNumber: "000-00-0000") { json, error in
            self.stripeService.getVerification { json, error in
                guard let json = json,
                    let fieldsNeeded = json["fields_needed"] as? [String] else {
                        XCTAssert(false, "Should have json")
                        return
                }
                
                XCTAssert(fieldsNeeded.contains("legal_entity.personal_id_number") == false, "Should have set external account")
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetMechanic() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getCurrentMechanic { json, error in
            if let json = json {
                XCTAssert(json["isActive"] as? Bool != nil, "Should have gotten at least one mechanic")
                XCTAssert(json["id"] as? String != nil, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testGetStats() {
        let exp = expectation(description: "\(#function)\(#line)")
        let mechanicID = "ce8b0070-0e41-11e9-834e-458588e04d18"
        service.getStats(forMechanicWithID: mechanicID) { json, error in
            if let json = json?[mechanicID] as? JSONObject {
                XCTAssert(json["autoServicesProvided"] as? Int != nil, "Should have existed")
                XCTAssert(json["numberOfRatings"] as? Int != nil, "Should have existed")
                XCTAssert(json["averageRating"] as? CGFloat != nil, "Should have existed")
            } else {
                XCTAssert(false, "Should have gotten json")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testPerformanceNearestMechanics() {
        measure {
            let exp = expectation(description: "\(#function)\(#line)")
            service.getNearestMechanics(limit: 10, latitude: closeLatitude, longitude: closeLongitude, maxDistance: 1000) { jsonArray, error in
                exp.fulfill()
            }
            waitForExpectations(timeout: 40, handler: nil)
        }
    }
    
    func testGetMechanics() {
        let exp = expectation(description: "\(#function)\(#line)")
        service.getMechanics(limit: 30, offset: 0, sortType: .ascending) { jsonArray, err in
            if let jsonArray = jsonArray {
                XCTAssert(jsonArray.count > 0, "Should have gotten at least one mechanic")
            } else {
                XCTAssert(false, "Should have gotten jsonArray")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }

    func testUpdateMechanicCorperate() {
        let exp = expectation(description: "\(#function)\(#line)")
        let mechanicID = "39895440-8fd8-11e9-a0b9-ff60380afd50"
        let isAllowed = true
        service.updateMechanicCorperate(mechanicID: mechanicID, isAllowed: isAllowed) { mechanicJSON, error in
            XCTAssert(mechanicJSON != nil, "Should have mechanic")
            let jsonIsAllowed = mechanicJSON?["isAllowed"] as! Bool
            XCTAssert(jsonIsAllowed == isAllowed, "Should have isAllowed. Set as: \(isAllowed), got \(jsonIsAllowed)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
