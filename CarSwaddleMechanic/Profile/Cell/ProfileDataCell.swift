//
//  ProfileDataCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class ProfileDataCell: UITableViewCell, NibRegisterable {

    var descriptionText: String? {
        didSet {
            updateText()
        }
    }
    
    var valueText: String? {
        didSet {
            updateText()
        }
    }
    
    private func updateText() {
        if let valueText = valueText {
            descriptionLabel.isHiddenInStackView = false
            descriptionLabel.text = descriptionText
            valueLabel.text = valueText
        } else {
            descriptionLabel.isHiddenInStackView = true
            valueLabel.text = descriptionText
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
    }
    
}
