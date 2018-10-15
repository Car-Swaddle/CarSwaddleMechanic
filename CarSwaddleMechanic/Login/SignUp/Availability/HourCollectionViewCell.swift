//
//  HourCollectionViewCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI



final class HourCollectionViewCell: UICollectionViewCell, NibRegisterable {
    
    static var dateFormatter: DateFormatter = {
        let dateAsString = "13:15"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        return dateFormatter
    }()
    
//    let date = dateFormatter.date(from: dateAsString)
//    dateFormatter.dateFormat = "h:mm a"
//    let Date12 = dateFormatter.string(from: date!)
    
    @IBOutlet private weak var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with hour: Hour) {
        let hour12 = (hour.value % 12)+1
        hourLabel.text = "\(hour12)am"
        hourLabel.backgroundColor = hour.isSelected ? .lightGray : .white
    }
    
}
