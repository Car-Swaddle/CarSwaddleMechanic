//
//  StripeTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store


class StripeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? store.destroyAllData()
    }
    
    func testCreateBalance() {
        let context = store.mainContext
        let balance = Balance(json: balanceJSON, context: context)
        context.persist()
        XCTAssert(balance != nil, "Must have region from: \(balanceJSON)")
    }
    
    func testCreateBalanceReserved() {
        let context = store.mainContext
        var json = balanceJSON
        json["connect_reserved"] = nil
        let balance = Balance(json: json, context: context)
        context.persist()
        XCTAssert(balance != nil, "Must have region from: \(json)")
    }
    
    func testTransaction() {
        let context = store.mainContext
        let json = singleTransaction
        let transaction = Transaction(json: json, context: context)
        context.persist()
        XCTAssert(transaction != nil, "Must have transaction from: \(json)")
    }
    
    func testPayout() {
        let context = store.mainContext
        let json = singlePayoutJSON
        let transaction = Payout(json: json, context: context)
        context.persist()
        XCTAssert(transaction != nil, "Must have transaction from: \(json)")
    }
    
}


private let balanceJSON: [String: Any] = [
    "object": "balance",
    "available": [
        [
            "amount": Int(0),
            "currency": "usd",
            "source_types": [
                "card": Int(0)
            ]
        ]
    ],
    "connect_reserved": [
        [
            "amount": Int(0),
            "currency": "usd"
        ]
    ],
    "livemode": false,
    "pending": [
        [
            "amount": Int(3466),
            "currency": "usd",
            "source_types": [
                "card": Int(3466)
            ]
        ]
    ]
]

private let singleTransaction: [String: Any] = [
    "id": "txn_1DrkLNEuZcoNxiqA9hcSyMmJ",
    "object": "balance_transaction",
    "amount": 4983,
    "available_on": 1547856000,
    "created": 1547291281,
    "currency": "usd",
    "description": NSNull(),
    "exchange_rate": NSNull(),
    "fee": 0,
    "fee_details": [],
    "net": 4983,
    "source": "py_1DrkLNEuZcoNxiqAGScYdQpJ",
    "status": "pending",
    "type": "payment"
]

private let transactionJSON: [String: Any] = [
    "object": "list",
    "data": [
        singleTransaction,
    ],
    "has_more": false,
    "url": "/v1/balance/history"
]



private let singlePayoutJSON: [String: Any] = [
    "id": "po_1DqZdvIh8ecz19vMYb1rjevk",
    "object": "payout",
    "amount": 1100,
    "arrival_date": 1547011819,
    "automatic": true,
    "balance_transaction": "txn_1DqJ29Ih8ecz19vM7fhLl9es",
    "created": 1547011819,
    "currency": "usd",
    "description": "STRIPE PAYOUT",
    "destination": "ba_1DqZdvIh8ecz19vMDENxxBzz",
    "failure_balance_transaction": NSNull(),
    "failure_code": NSNull(),
    "failure_message": NSNull(),
    "livemode": false,
    "metadata": [],
    "method": "standard",
    "source_type": "card",
    "statement_descriptor": NSNull(),
    "status": "in_transit",
    "type": "bank_account"
]

private let payoutJSON: [String: Any] = [
    "object": "list",
    "url": "/v1/payouts",
    "has_more": false,
    "data": [singlePayoutJSON],
]
