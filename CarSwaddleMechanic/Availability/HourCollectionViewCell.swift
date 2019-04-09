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
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
}()

private var dateComponents: DateComponents = {
    var dateComponents = DateComponents()
    return dateComponents
}()

private let calendar = Calendar.current

final class HourCollectionViewCell: UICollectionViewCell, NibRegisterable {
    
    @IBOutlet private weak var pillView: UIView!
    @IBOutlet private weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        
        hourLabel.font = UIFont.appFont(type: .semiBold, size: 14)
        
        pillView.backgroundColor = .white
        hourLabel.textColor = .black
        pillView.clipsToBounds = false
        
        pillView.layer.shadowOpacity = 0.2
        pillView.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pillView.layer.cornerRadius = pillView.frame.height/2
    }
    
    func configure(with hour: Hour) {
        dateComponents.hour = hour.value
        if let date = calendar.date(from: dateComponents) {
            hourLabel.text = hourDateFormatter.string(from: date).lowercased()
        }
        pillView.backgroundColor = self.backgroundColor(for: hour)
        hourLabel.textColor = self.textColor(for: hour)
    }
    
    private func backgroundColor(for hour: Hour) -> UIColor {
        return hour.isSelected ? .secondary : .white
    }
    
    private func textColor(for hour: Hour) -> UIColor {
        return hour.isSelected ? .white : .black
    }
    
}
