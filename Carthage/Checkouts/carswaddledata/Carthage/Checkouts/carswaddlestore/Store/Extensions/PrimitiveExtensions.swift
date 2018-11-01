//
//  PrimitiveExtesions.swift
//  Store
//
//  Created by Kyle Kendall on 11/1/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation


public extension Int64 {
    
    public var numberOfDigits: Int {
        var numberOfDigits: Int = 0
        var dividedValue = self
        while dividedValue > 0 {
            dividedValue = dividedValue / 10
            numberOfDigits += 1
        }
        return numberOfDigits
    }
    
    public var timeOfDayFormattedString: String {
        let hours = self / (60*60)
        let minutes = (self / 60) % 60
        let seconds = self % 60
        
        var hoursString: String = String(hours)
        if hours.numberOfDigits < 2 {
            hoursString = "0" + hoursString
        }
        var minutesString: String = String(minutes)
        if minutes.numberOfDigits < 2 {
            minutesString = "0" + minutesString
        }
        var secondsString: String = String(seconds)
        if seconds.numberOfDigits < 2 {
            secondsString = "0" + secondsString
        }
        
        return hoursString + ":" + minutesString + ":" + secondsString
    }
    
}
