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
    
    func testPayoutTransaction() {
        let context = store.mainContext
        let json = payoutTransaction
        let transaction = Transaction(json: json, context: context)
        transaction?.mechanic = Mechanic(json: mechanicJSON, context: context)
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
    
    func testPaidPayout() {
        let context = store.mainContext
        let json = paidPayout
        let payout = Payout(json: json, context: context)
        context.persist()
        print(payout ?? "")
        XCTAssert(payout != nil, "Must have transaction from: \(json)")
    }
    
    func testBankAccount() {
        let context = store.mainContext
        let json = bankAccountJSON
//        let payout = Payout(json: json, context: context)
        let bankAccount = BankAccount(json: json, context: context)
        context.persist()
        print(bankAccount ?? "")
        XCTAssert(bankAccount != nil, "Must have transaction from: \(json)")
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


private let payoutTransaction: [String: Any] = [
    "id": "txn_1Dt2vhFJ56E8lSb9u4JFpEkN",
    "object": "balance_transaction",
    "amount": -14194,
    "available_on": 1547683200,
    "created": 1547601053,
    "currency": "usd",
    "description": "STRIPE PAYOUT",
    "exchange_rate": NSNull(),
    "fee": 0,
    "fee_details": [],
    "net": -14194,
    "source": "po_1Dt2vhFJ56E8lSb9Err8HxqR",
    "status": "pending",
    "type": "payout"
]

private let paidPayout: [String: Any] = [
    "id": "po_1DsgRZFJ56E8lSb9gAVqUVtr",
    "object": "payout",
    "amount": 13822,
    "arrival_date": 1547596800,
    "automatic": true,
    "balance_transaction": "txn_1DsgRZFJ56E8lSb9WLgQy6Ap",
    "created": 1547514617,
    "currency": "usd",
    "description": "STRIPE PAYOUT",
    "destination": "ba_1DqdBoFJ56E8lSb9I1RpATDg",
    "failure_balance_transaction": NSNull(),
    "failure_code": NSNull(),
    "failure_message": NSNull(),
    "livemode": false,
    "metadata": [],
    "method": "standard",
    "source_type": "card",
    "statement_descriptor": NSNull(),
    "status": "paid",
    "type": "bank_account"
]


let bankAccountJSON: [String: Any] = [
    "id": "ba_1E8K2aIucYRP2W8I3sd9uLzp",
    "object": "bank_account",
    "account": "acct_1E8Js0IucYRP2W8I",
    "account_holder_name": "Rupert McGee",
    "account_holder_type": "individual",
    "bank_name": "STRIPE TEST BANK",
    "country": "US",
    "currency": "usd",
    "default_for_currency": true,
    "fingerprint": "UvOlySjRzdmjSwkF",
    "last4": "6789",
    "metadata": {},
    "routing_number": "110000000",
    "status": "new"
]
