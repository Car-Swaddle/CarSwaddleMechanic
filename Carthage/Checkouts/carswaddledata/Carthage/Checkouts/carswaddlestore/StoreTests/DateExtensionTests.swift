//
//  DateExtensionTests.swift
//  StoreTests
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import Store

class DateExtensionTests: XCTestCase {
    
    func testSecondsSinceMidnight() {
        //        let oneSecondDate = Date(timeIntervalSinceReferenceDate: 1)
        let oneSecondDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: Date())!
        let seconds = oneSecondDate.secondsSinceMidnight()
        XCTAssert(seconds == 1, "Should have gotten 1 here, got: \(seconds) seconds from date: \(oneSecondDate)")
        
        let longDate = Calendar.current.date(bySettingHour: 15, minute: 30, second: 38, of: Date())!
        let longSeconds = longDate.secondsSinceMidnight()
        XCTAssert(longSeconds == (15*60*60) + (30*60) + 38, "Should have gotten 1 here, got: \(seconds) seconds from date: \(oneSecondDate)")
    }
    
}

