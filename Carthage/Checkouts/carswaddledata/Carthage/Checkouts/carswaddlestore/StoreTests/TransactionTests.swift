//
//  TransactionTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 2/4/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store

class TransactionTests: XCTestCase {
    
    func testCreateTransaction() {
        try? store.destroyAllData()
        let context = store.mainContext
        let json = transactionJSON
        let transaction = Transaction(json: json, context: context)
        
        XCTAssert(transaction?.transactionMetadata != nil, "Should have meta")
        
        context.persist()
    }
    
    func testCreateTransactionMetadata() {
        try? store.destroyAllData()
        let context = store.mainContext
        let json = transactionMetadataJSON
        let transactionMetadata = TransactionMetadata(json: json, context: context)
        
        XCTAssert(transactionMetadata?.receipts.count == 1, "Should have 1 receipt")
        
        context.persist()
    }
    
}


let transactionMetadataJSON: [String: Any] = [
    "id": "5d9ea4a0-280b-11e9-9ec0-0fdadcffb18f",
    "stripeTransactionID": "txn_1DzuNcEUGV6ByO73IAFoguV7",
    "mechanicCost": 4570,
    "drivingDistance": 6210,
    "createdAt": "2019-02-03T23:28:09.194Z",
    "updatedAt": "2019-02-03T23:28:13.748Z",
    "autoServiceID": "5a7b6ba0-280b-11e9-9ec0-0fdadcffb18f",
    "mechanicID": "0810bf11-280a-11e9-9edd-ab7b89f43360",
    "transactionReceipts": [
        [
            "id": "3fae2570-2846-11e9-b978-a7aee4f70dd4",
            "receiptPhotoID": "3b2e42a0-2846-11e9-b978-a7aee4f70dd4",
            "updatedAt": "2019-02-04T06:29:41.757Z",
            "createdAt": "2019-02-04T06:29:39.273Z",
            "transactionMetadataID": "5d9ea4a0-280b-11e9-9ec0-0fdadcffb18f"
        ]
    ]
]

let transactionJSON: [String: Any] = [
    "id": "txn_1DzuNcEUGV6ByO73IAFoguV7",
    "object": "balance_transaction",
    "amount": 5172,
    "available_on": 1549756800,
    "created": 1549236484,
    "currency": "usd",
    "description": NSNull(),
    "exchange_rate": NSNull(),
    "fee": 0,
    "fee_details": [],
    "net": 5172,
    "source": "py_1DzuNcEUGV6ByO73y3YHmkkV",
    "status": "pending",
    "type": "payment",
    "car_swaddle_meta": [
        "id": "5d9ea4a0-280b-11e9-9ec0-0fdadcffb18f",
        "stripeTransactionID": "txn_1DzuNcEUGV6ByO73IAFoguV7",
        "mechanicCost": 1567,
        "drivingDistance": 1499,
        "createdAt": "2019-02-03T23:28:09.194Z",
        "updatedAt": "2019-02-04T06:07:30.108Z",
        "autoServiceID": "5a7b6ba0-280b-11e9-9ec0-0fdadcffb18f",
        "mechanicID": "0810bf11-280a-11e9-9edd-ab7b89f43360",
        "transactionReceipts": [
            [
                "id": "3fae2570-2846-11e9-b978-a7aee4f70dd4",
                "receiptPhotoID": "3b2e42a0-2846-11e9-b978-a7aee4f70dd4",
                "createdAt": "2019-02-04T06:29:39.273Z",
                "updatedAt": "2019-02-04T06:29:41.757Z",
                "transactionMetadataID": "5d9ea4a0-280b-11e9-9ec0-0fdadcffb18f"
            ]
        ]
    ]
    
]
