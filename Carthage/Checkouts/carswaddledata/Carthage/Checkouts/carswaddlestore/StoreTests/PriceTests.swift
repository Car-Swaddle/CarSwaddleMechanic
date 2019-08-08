//
//  PriceTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 12/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store

class PriceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? store.destroyAllData()
        store.mainContext.persist()
    }
    
    func testCreatePrice() {
        let price = Price.fetchOrCreate(json: invoicePriceJSON, context: store.mainContext)
        XCTAssert(price != nil, "Should have price")
        
        store.mainContext.persist()
    }
    
    func testCreatePriceCoupon() {
        let price = Price.fetchOrCreate(json: invoicePriceWithCouponJSON, context: store.mainContext)
        XCTAssert(price != nil, "Should have price")
        XCTAssert(price?.couponDiscount != nil, "Should have couponDiscount")
        
        store.mainContext.persist()
    }
    
}

private let price4PricePartJSON: [String: Any] = [
    "id": "234567-12345678909876543-76543234",
    "autoServiceID": NSNull(),
    "totalPrice": "12312.987473721723",
    "priceParts": [
        ["key": "labor", "value": "11.356770603616"],
        ["key": "oilFilter", "value": "9.5"],
        ["key": "distance", "value": "11.89"],
        ["key": "subtotal", "value": "11.356770603616"],
    ]
]

private let price6PricePartJSON: [String: Any] = [
    "id": "234567-12345678909876543-76543234",
    "autoServiceID": NSNull(),
    "totalPrice": "12312.987473721723",
    "priceParts": [
        ["key": "labor", "value": "11.356770603616"],
        ["key": "oilFilterUnique", "value": "9.5"],
        ["key": "distanceUnique", "value": "11.89"],
        ["key": "subtotalUnique", "value": "11.356770603616"],
        ["key": "bookingFee", "value": "5"],
        ["key": "processingFee", "value": "1.34"],
    ]
]

private let invoicePriceWithCouponJSON: [String: Any] = [
    "prices": [
        "bookingFee": 487,
        "bookingFeeDiscount": NSNull(),
        "discount": -30,
        "distance": 369,
        "mechanicCost": 3408,
        "oilChange": 4500,
        "processingFee": 224,
        "subtotal": 4869,
        "taxes": 397,
        "total": 5947,
        "transferAmount": 4869,
    ]
]

private let invoicePriceJSON: [String: Any] = [
    "prices": [
        "oilChange": 4500,
        "distance": 1600,
        "bookingFee": 480,
        "processingFee": 480,
        "bookingFeeDiscount": 0,
        "subtotal": 6580,
        "taxes": 230,
        "total": 6820
    ]
]


/*
 ["autoServiceID": <null>, "totalPrice": 12312.987473721723, "createdAt": 2018-12-21T02:44:53.369Z, "updatedAt": 2018-12-21T02:44:53.369Z, "id": 64de0e90-04ca-11e9-bced-6f155d6954c0, "priceParts": <__NSArrayI 0x6000024945a0>(
 {
 key = labor;
 value = 12;
 },
 {
 key = oilFilter;
 value = "9.5";
 },
 {
 key = distance;
 value = "11911.356770603616";
 },
 {
 key = oil;
 value = "16.5";
 },
 {
 key = subtotal;
 value = "11949.356770603616";
 },
 {
 key = bookingFee;
 value = 5;
 },
 {
 key = processingFee;
 value = "358.63070311810844";
 }
 )
 ]
 (lldb)
 */
