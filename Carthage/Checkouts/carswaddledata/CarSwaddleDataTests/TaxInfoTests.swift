//
//  TaxInfoTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store


class TaxInfoTests: LoginTestCase {
    
    let taxService: TaxNetwork = TaxNetwork(serviceRequest: serviceRequest)
    
    func testTaxYear() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        store.privateContext { privateContext in
            self.taxService.requestTaxYears(in: privateContext) { taxInfoObjectIDs, error in
                store.mainContext { mainContext in
                    for objectID in taxInfoObjectIDs {
                        let taxInfo = mainContext.object(with: objectID) as? TaxInfo
                        XCTAssert(taxInfo != nil, "Should have tax Info")
                    }
                    XCTAssert(taxInfoObjectIDs.count > 0 , "Should have tax Info")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testTaxYearInfo() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.taxService.requestTaxInfo(year: "2019", in: privateContext) { taxInfoObjectID, error in
                store.mainContext { mainContext in
                    XCTAssert(taxInfoObjectID != nil , "Should have tax Info")
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
