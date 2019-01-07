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
        let location = CLLocationCoordinate2D(latitude: 40.36, longitude: -111.8657987654)
        priceService.getPrice(mechanicID: currentMechanicID, oilType: "CONVENTIONAL", location: location) { json, error in
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
