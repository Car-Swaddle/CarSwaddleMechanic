//
//  HourCollectionViewCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h a"
    return dateFormatter
}()

private var dateComponents: DateComponents = {
    var dateComponents = DateComponents()
    return dateComponents
}()

private let calendar = Calendar.current

final class HourCollectionViewCell: UICollectionViewCell, NibRegisterable {
    
//    private static let dateFormatterForCreation: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter
//    }()
    
    
    @IBOutlet private weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with hour: Hour) {
        dateComponents.hour = hour.value
        if let date = calendar.date(from: dateComponents) {
            hourLabel.text = dateFormatter.string(from: date).lowercased()
        }
        hourLabel.backgroundColor = hour.isSelected ? .lightGray : .white
    }
    
}

//extension Date {
//
//    public func secondsSinceMidnight() -> Int {
//        let units: Set<Calendar.Component>  = [.hour, .minute, .second]
//        let components = Calendar.current.dateComponents(units, from: self)
//        let hoursInSeconds = 60 * 60 * (components.hour ?? 0)
//        let minutesInSeconds = 60 * (components.minute ?? 0)
//        return hoursInSeconds + minutesInSeconds + (components.second ?? 0)
//    }
//
//}
//
//public extension Int64 {
//
//    public var numberOfDigits: Int {
//        var numberOfDigits: Int = 0
//        var dividedValue = self
//        while dividedValue > 0 {
//            dividedValue = dividedValue / 10
//            numberOfDigits += 1
//        }
//        return numberOfDigits
//    }
//
//    public var timeOfDayFormattedString: String {
//        let hours = self / (60*60)
//        let minutes = (self / 60) % 60
//        let seconds = self % 60
//
//        var hoursString: String = String(hours)
//        if hours.numberOfDigits < 2 {
//            hoursString = "0" + hoursString
//        }
//        var minutesString: String = String(minutes)
//        if minutes.numberOfDigits < 2 {
//            minutesString = "0" + minutesString
//        }
//        var secondsString: String = String(seconds)
//        if seconds.numberOfDigits < 2 {
//            secondsString = "0" + secondsString
//        }
//
//        return hoursString + ":" + minutesString + ":" + secondsString
//    }
//
//}
