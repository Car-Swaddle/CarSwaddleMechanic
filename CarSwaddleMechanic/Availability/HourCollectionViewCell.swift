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

private let hourDateFormatter: DateFormatter = {
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
            hourLabel.text = hourDateFormatter.string(from: date).lowercased()
        }
        hourLabel.backgroundColor = hour.isSelected ? .lightGray : .white
    }
    
}
