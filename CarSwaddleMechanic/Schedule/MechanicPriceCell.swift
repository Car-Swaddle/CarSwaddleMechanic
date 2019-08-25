//
//  MechanicPriceCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 8/21/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

class MechanicPriceCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with value: String) {
        textLabel?.text = value
    }
    
    func configure(with value: Int) {
        textLabel?.text = value.stringValue
    }
    
    
}
