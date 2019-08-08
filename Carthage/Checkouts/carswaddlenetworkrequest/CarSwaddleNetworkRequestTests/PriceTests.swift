//
//  PriceTests.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 12/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleNetworkRequest
import Authentication
import MapKit


class PriceTests: CarSwaddleLoginTestCase {
    
    private let priceService = PriceService(serviceRequest: serviceRequest)
    
    func testGetPrice() {
        let exp = expectation(description: "\(#function)\(#line)")
        priceService.getPrice(mechanicID: "60a8ca60-a03b-11e9-b54d-d938b4077b64", oilType: "CONVENTIONAL", locationID: "66513230-a03c-11e9-b54d-d938b4077b64", couponCode: "30off") { json, error in
            XCTAssert(json != nil, "Should have at least one json object")
            XCTAssert(error == nil, "Should have not have error")
            
            if let json = json,
                let totalPrice = json["totalPrice"],
                let totalPriceString = totalPrice as? String {
                let decimal = NSDecimalNumber(string: totalPriceString)
                print("type: \(type(of: totalPrice)), decimal: \(decimal)")
            }
            
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
