//
//  DateExtension.swift
//  Store
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension Date {
    
    public func secondsSinceMidnight() -> Int {
        let units: Set<Calendar.Component>  = [.hour, .minute, .second]
        let components = Calendar.current.dateComponents(units, from: self)
        let hoursInSeconds = 60 * 60 * (components.hour ?? 0)
        let minutesInSeconds = 60 * (components.minute ?? 0)
        return hoursInSeconds + minutesInSeconds + (components.second ?? 0)
    }
    
}
