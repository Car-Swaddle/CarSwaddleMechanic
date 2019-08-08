//
//  CouponTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store

class CouponTests: LoginTestCase {
    
    let couponNetwork = CouponNetwork(serviceRequest: serviceRequest)
    
    private let testCouponID = UUID().uuidString
    
    func testGetCoupons() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.couponNetwork.getCoupons(in: privateContext) { objectIDs, error in
                XCTAssert(objectIDs.count > 0, "Should have coupons")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteCoupon() {
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.couponNetwork.deleteCoupon(id: "6EDF1009-73FD-40C9-8B00-E22466B6CE7A", in: privateContext) { error in
                XCTAssert(error != nil, "Got error")
                let coupon = Coupon.fetch(with: "test", in: privateContext)
                XCTAssert(coupon == nil, "Should be deleted")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateCouponAmountOff() {
        let testCouponID = self.testCouponID
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.couponNetwork.createCoupon(id: testCouponID, discount: .amountOff(value: 30), maxRedemptions: 40, name: "Notha test" + UUID().uuidString, redeemBy: Date().addingTimeInterval(24*60*60), discountBookingFee: false, isCorporate: true, in: privateContext) { objectID, error in
                if let objectID = objectID {
                    let coupon = (privateContext.object(with: objectID) as? Coupon)
                    XCTAssert(coupon != nil, "Should have coupon")
                }
                XCTAssert(objectID != nil, "Should have coupon")
                print("testCouponID: \(testCouponID)")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateCouponPercentOff() {
        let testCouponID = self.testCouponID
        let exp = expectation(description: "\(#function)\(#line)")
        store.privateContext { privateContext in
            self.couponNetwork.createCoupon(id: testCouponID, discount: .percentOff(value: 30), maxRedemptions: 40, name: "Notha test" + UUID().uuidString, redeemBy: Date().addingTimeInterval(24*60*60), discountBookingFee: false, isCorporate: true, in: privateContext) { objectID, error in
                if let objectID = objectID {
                    let coupon = (privateContext.object(with: objectID) as? Coupon)
                    XCTAssert(coupon != nil, "Should have coupon")
                }
                XCTAssert(objectID != nil, "Should have coupon")
                print("testCouponID: \(testCouponID)")
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}
