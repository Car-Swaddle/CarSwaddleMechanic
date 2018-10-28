//
//  TemplateTimeSpanTests.swift
//  CarSwaddleDataTests
//
//  Created by Kyle Kendall on 10/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import CarSwaddleData
import CoreData
import Store

class TemplateTimeSpanTests: LoginTestCase {
    
    let network = TemplateTimeSpanNetwork()
    
    override func setUp() {
        super.setUp()
        let context = store.mainContext
        let user = User.fetch(with: userID, in: context) ?? User(json: userJSON, context: context)
        let mechanic = Mechanic.fetch(with: mechanicID, in: context) ?? Mechanic(context: context)
        mechanic.identifier = mechanicID
        mechanic.isActive = true
        mechanic.user = user
        
        let allTTS = TemplateTimeSpan.fetchAllObjects(with: [NSSortDescriptor(key: #keyPath(TemplateTimeSpan.identifier), ascending: true)], in: context)
        for tts in allTTS {
            context.delete(tts)
        }
        
        context.persist()
    }
    
    
    func testSavingTemplateTimeSpans() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        network.getTimeSpans(in: context) { ids, error in
            XCTAssert(ids.count > 0, "Should have ids")
            print(ids)
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreatingTemplateTimeSpanJSON() {
        let new = TemplateTimeSpan(json: validTTSJSON, context: store.mainContext)
        store.mainContext.persist()
        XCTAssert(new != nil && new?.startTime == (7*60*60) + (9*60), "Should have new TTS")
    }

}


let userID = "3456-1234567876543-34567"
let mechanicID = "3456-1234567876543-987654"

let validTTSJSON: [String: Any] = [
    "id": "2345678-7654345676543-6543",
    "duration": Double(3600),
    "weekDay": Int16(0),
    "startTime": "07:09:00",
    "mechanicID": mechanicID,
]

let userJSON: [String: Any] = [
    "firstName": "Rupert",
    "lastName": "Rupertarious",
    "phoneNumber": "928-273-8726",
    "id": userID
]
