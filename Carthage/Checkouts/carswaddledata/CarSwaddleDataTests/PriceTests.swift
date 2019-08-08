//
//  PriceTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 12/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store
import MapKit

class PriceTests: LoginTestCase {
    
    private let priceNetwork: PriceNetwork = PriceNetwork(serviceRequest: serviceRequest)
    
    func testRequestPrice() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { pCtx in
            let location = CLLocationCoordinate2D(latitude: 40.36878163199601, longitude: -111.85300827026369)
//            self.priceNetwork.requestPrice(mechanicID: "60a8ca60-a03b-11e9-b54d-d938b4077b64", oilType: .conventional, locationID: "66513230-a03c-11e9-b54d-d938b4077b64", couponCode: nil, in: pCtx) { objectID, error in
            self.priceNetwork.requestPrice(mechanicID: "60a8ca60-a03b-11e9-b54d-d938b4077b64", oilType: .conventional, location: location, couponCode: nil, in: pCtx) { objectID, error in
                store.mainContext { mCtx in
                    guard let objectID = objectID else {
                        XCTAssert(false, "No objectID")
                        return
                    }
                    guard let price = mCtx.object(with: objectID) as? Price else {
                        XCTAssert(false, "No price")
                        return
                    }
//                    XCTAssert(price.parts.count > 0, "Should have parts")
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
