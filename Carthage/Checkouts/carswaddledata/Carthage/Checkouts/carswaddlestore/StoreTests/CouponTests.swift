//
//  CouponTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


import XCTest
@testable import Store

class CouponTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? store.destroyAllData()
        store.mainContext.persist()
    }
    
    func testCreateAuthority() {
        let coupon = Coupon.fetchOrCreate(json: couponJSON, context: store.mainContext)
        
        XCTAssert(coupon != nil, "Should have coupon")
        
        let result = store.mainContext.persist()
        XCTAssert(result, "Should be true")
    }
    
}

private let couponJSON: [String: Any] = [
    "id": "testnoob",
    "amountOff": 30,
    "percentOff": NSNull(),
    "redemptions": 0,
    "maxRedemptions": 1,
    "name": "Marks test 1",
    "redeemBy": "2019-07-31T02:38:08.948Z",
    "discountBookingFee": false,
    "isCorporate": true,
    "createdAt": "2019-07-15T05:51:26.008Z",
    "updatedAt": "2019-07-15T05:51:26.008Z",
    "createdByUserID": "eaee8570-a6c1-11e9-84f4-dd5b313f5310",
    "createdByMechanicID": NSNull()
]

