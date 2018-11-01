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
    
    let network = TemplateTimeSpanNetwork(serviceRequest: serviceRequest)
    
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
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testCreatingTemplateTimeSpanJSON() {
        let new = TemplateTimeSpan(json: validTTSJSON, context: store.mainContext)
        store.mainContext.persist()
        XCTAssert(new != nil && new?.startTime == (7*60*60) + (9*60), "Should have new TTS")
    }
    
    func testPostingNewTemplateTimeSpans() {
        let exp = expectation(description: "\(#function)\(#line)")
        let context = store.mainContext
        
        let templateTimeSpans: [TemplateTimeSpan] = createTemplateTimeSpans(in: context)
        let originalCount = templateTimeSpans.count
        context.persist()
        network.postTimeSpans(templateTimeSpans: templateTimeSpans, in: context) { ids, error in
            XCTAssert(ids.count == originalCount, "Should have ids")
            exp.fulfill()
        }
        waitForExpectations(timeout: 40, handler: nil)
    }
    
    func testToJSON() {
        let originalJSON = validTTSJSON
        let new = TemplateTimeSpan(json: originalJSON, context: store.mainContext)
        guard let json = new?.toJSON else {
            XCTAssert(false, "Should have json")
            return
        }
        
        let startTime = json["startTime"] as? Int64
        XCTAssert(json["duration"] as? Double == originalJSON["duration"] as? Double, "Should have correct json. Got \(json), should be: \(originalJSON)")
        XCTAssert(json["weekDay"] as? Int16 == originalJSON["weekDay"] as? Int16, "Should have correct json. Got \(json), should be: \(originalJSON)")
        XCTAssert(startTime == 25740, "Should have correct json. Got \(String(describing: startTime)), should be: \(25740)")
    }
    
    func testStartTimeSpringFormat() {
        let new = TemplateTimeSpan(json: validTTSJSON, context: store.mainContext)
        guard let formattedTime = new?.startTimeStringFormat else {
            XCTAssert(false, "Should have gotten template")
            return
        }
        
        let correctFormat = "07:09:00"
        
        XCTAssert(formattedTime == correctFormat, "Start time format looks like: \(formattedTime), should look like \(correctFormat)")
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
