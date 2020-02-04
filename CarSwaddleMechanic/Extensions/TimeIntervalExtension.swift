//
//  TimeIntervalExtension.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    static let minute: TimeInterval = 60
    static let hour: TimeInterval = .minute*60
    static let day: TimeInterval = .hour*24
    static let week: TimeInterval = .day*7
    
    public var days: TimeInterval {
        return self.hours / 24
    }
    
    public var minutes: TimeInterval {
        return self / 60.0
    }
    
    public var hours: TimeInterval {
        return self.minutes / 60.0
    }
    
}

extension Date {
    
    var dayAfter: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self, wrappingComponents: false)
    }
    
    var dayBefore: Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self, wrappingComponents: false)
    }
    
    func dateByAdding(years: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: years, to: self, wrappingComponents: false)
    }
    
    func dateByAdding(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self, wrappingComponents: false)
    }
    
    var dayOfWeek: Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
}
