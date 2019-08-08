//
//  VerificationTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store

class VerificationTests: XCTestCase {

    func testEmptyVerificationFromJSON() {
        let json = emptyVerificationJSON
        let verification = Verification(json: json, context: store.mainContext)
        store.mainContext.persist()
//        XCTAssert(verification.fields.count == 0, "Failed")
        XCTAssert(verification.disabledReason == nil, "Failed")
        XCTAssert(verification.dueByDate == nil, "Failed")
    }
    
    func testDisabledReasonVerificationFromJSON() {
        let json = disabledReasonVerificationJSON
        let verification = Verification(json: json, context: store.mainContext)
        store.mainContext.persist()
//        XCTAssert(verification.fields.count == 0, "Failed")
        XCTAssert(verification.disabledReason != nil, "Failed")
        XCTAssert(verification.typedDisabledReason == .rejectedFraud, "Failed")
        XCTAssert(verification.dueByDate == nil, "Failed")
    }
    
    func testDisabledAndDueDateReasonVerificationFromJSON() {
        let json = disabledReasonDueDateVerificationJSON
        let verification = Verification(json: json, context: store.mainContext)
        store.mainContext.persist()
//        XCTAssert(verification.fields.count == 0, "Failed")
        XCTAssert(verification.disabledReason != nil, "Failed")
        XCTAssert(verification.typedDisabledReason == .rejectedListed, "Failed")
        XCTAssert(verification.dueByDate != nil, "Failed")
    }
    
    func testFullVerificationJSON() {
        let json = fullVerificationJSON
        let verification = Verification(json: json, context: store.mainContext)
        store.mainContext.persist()
//        XCTAssert(verification.fields.map{ $0.typedValue }.count == VerificationField.Field.allCases.count, "Failed")
        XCTAssert(verification.disabledReason != nil, "Failed")
        XCTAssert(verification.typedDisabledReason == .rejectedListed, "Failed")
        XCTAssert(verification.dueByDate != nil, "Failed")
    }

}

let emptyVerificationJSON: [String: Any] = [
    "disabled_reason": NSNull(),
    "due_by": NSNull(),
    "fields_needed": []
]

let disabledReasonVerificationJSON: [String: Any] = [
    "disabled_reason": "rejected.fraud",
    "due_by": NSNull(),
    "fields_needed": []
]

let disabledReasonDueDateVerificationJSON: [String: Any] = [
    "disabled_reason": "rejected.listed",
    "due_by": Double(83738.87),
    "fields_needed": []
]

let fullVerificationJSON: [String: Any] = [
    "disabled_reason": "rejected.listed",
    "due_by": Double(83738.87),
    "fields_needed": VerificationField.Field.allCases.map { $0.rawValue }
]
