//
//  LabelValueCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/8/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import UIKit

final class LabelValueCell: UITableViewCell, NibRegisterable {
    
    var labelText: String? {
        didSet {
            topLabel.text = labelText
        }
    }
    
    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        topLabel.font = UIFont.appFont(type: .regular, size: 15)
        valueLabel.font = UIFont.appFont(type: .regular, size: 17)
    }
    
}
