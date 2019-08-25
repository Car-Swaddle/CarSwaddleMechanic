//
//  CouponService.swift
//  CarSwaddleNetworkRequestTests
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation


import XCTest
@testable import CarSwaddleNetworkRequest

class CouponTests: CarSwaddleLoginTestCase {
    
    let couponService = CouponService(serviceRequest: serviceRequest)
    
    func testGetCoupons() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        couponService.getCoupons(limit: 30, offset: 0) { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testDeleteCoupon() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        couponService.deleteCoupon(couponID: "test") { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateCoupon() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        couponService.createCoupon(id: "test", amountOff: 30, percentOff: nil, maxRedemptions: 30, name: "Kyle's test coupon", redeemBy: Date().addingTimeInterval(24*60*60), discountBookingFee: false, isCorporate: true) { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreateCouponPercent() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        couponService.createCoupon(id: "test", amountOff: nil, percentOff: 35, maxRedemptions: 30, name: "Kyle's test coupon", redeemBy: Date().addingTimeInterval(24*60*60), discountBookingFee: false, isCorporate: true) { json, error in
            XCTAssert(json != nil && error == nil, "Should get values")
            json?.printObject()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}

