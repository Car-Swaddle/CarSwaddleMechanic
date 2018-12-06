//
//  TemplateTimeSpanTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 11/13/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
import CoreData
@testable import Store

class TemplateTimeSpanTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let context = store.mainContext
        let user = User.fetchOrCreate(json: userJSON, context: context)
//        let mechanic = Mechanic.fetch(with: mechanicID, in: context) ?? Mechanic(context: context)
        let mechanic = Mechanic.fetchOrCreate(json: mechanicJSON, context: context)
        mechanic?.user = user
        
        let allTTS = TemplateTimeSpan.fetchAllObjects(with: [NSSortDescriptor(key: #keyPath(TemplateTimeSpan.identifier), ascending: true)], in: context)
        for tts in allTTS {
            context.delete(tts)
        }
        
        context.persist()
    }
    
    func testCreateAndPersist() {
        
        let context = store.mainContext
        let mechanic = Mechanic.fetch(with: mechanicID, in: context)
        
        let tJSON = createValidJSON(weekday: .sunday, duration: 3600, startTime: 3600)
        let timeSpan = TemplateTimeSpan(json: tJSON, context: context)
        
        XCTAssert(timeSpan?.mechanic != nil, "Mechanic should exist")
        
        if let timeSpan = timeSpan {
            XCTAssert(mechanic?.scheduleTimeSpans.contains(timeSpan) == true, "Mechanic should have time span")
            XCTAssert(timeSpan.mechanic == mechanic, "Mechanic should have time span")
        } else {
            XCTAssert(false, "should have a time span")
        }
    }
    
    func testCreateAndPersistDifferentContext() {
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        let context = store.mainContext
        let mechanic = Mechanic.fetch(with: mechanicID, in: context)
        
        let tJSON = createValidJSON(weekday: .sunday, duration: 3600, startTime: 3600)
        
        store.privateContext { pCtx in
            let timeSpan = TemplateTimeSpan(json: tJSON, context: context)
            
            pCtx.persist()
            
            let tObjectID = timeSpan?.objectID
            DispatchQueue.main.async {
                store.mainContext { mCtx in
                    
                    let mainTS = mCtx.object(with: tObjectID!) as! TemplateTimeSpan
                    
                    XCTAssert(mainTS.mechanic != nil, "Mechanic should exist")
                    
                    if let timeSpan = timeSpan {
                        XCTAssert(mechanic?.scheduleTimeSpans.contains(timeSpan) == true, "Mechanic should have time span")
                        XCTAssert(timeSpan.mechanic == mechanic, "Mechanic should have time span")
                    } else {
                        XCTAssert(false, "should have a time span")
                    }
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 40, handler: nil)
    }
    
}



let userID = "3456-1234567876543-34567"
let mechanicID = "3456-1234567876543-987654"


private func createTemplateTimeSpans(in context: NSManagedObjectContext) -> [TemplateTimeSpan] {
    
    var templateTimeSpans: [TemplateTimeSpan] = []
    
    let weekDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    for weekday in weekDays {
        let hour: Int64 = 3600
        let startTimes: [Int64] = [9, 10, 11, 12, 13, 14, 15, 16, 17]
        for startTime in startTimes {
            let duration: Double = 3600
            let json = createValidJSON(weekday: weekday, duration: duration, startTime: startTime * hour)
            if let t = TemplateTimeSpan(json: json, context: context) {
                templateTimeSpans.append(t)
            } else {
                print("couldn't create t")
            }
        }
    }
    return templateTimeSpans
}

private func createValidJSON(weekday: Weekday, duration: Double, startTime: Int64) -> JSONObject {
    let validTTSJSON: [String: Any] = [
        "id": "2345678-7654345676543-6543",
        "duration": duration,
        "weekDay": weekday.rawValue,
        "startTime": startTime.timeOfDayFormattedString,
        "mechanicID": mechanicID,
        ]
    return validTTSJSON
}

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

let mechanicJSON: [String: Any] = [
    "id": mechanicID,
    "isActive": true
]
