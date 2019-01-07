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
//        let price = Price(json: price4PricePartJSON, context: store.mainContext)
        let price = Price.fetchOrCreate(json: price4PricePartJSON, context: store.mainContext)
        XCTAssert(price != nil, "Should have price")
        XCTAssert(price?.parts.count == 4, "Should have 4 price parts")
        
        store.mainContext.persist()
        
        let price2 = Price.fetchOrCreate(json: price6PricePartJSON, context: store.mainContext)
        XCTAssert(price2 != nil, "Should have price")
        XCTAssert(price2?.parts.count == 6, "Should have 6 price parts")
        
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
