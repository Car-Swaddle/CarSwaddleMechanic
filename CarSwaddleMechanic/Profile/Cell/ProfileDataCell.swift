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

    var errorViewIsHidden: Bool = true {
        didSet {
            updateErrorViewHiddenStatus()
        }
    }
    
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
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateErrorViewCornerRadius()
    }
    
    private func updateErrorViewHiddenStatus() {
        errorView.isHiddenInStackView = errorViewIsHidden
    }
    
    private func updateErrorViewCornerRadius() {
        errorView.layer.cornerRadius = errorView.frame.height / 2
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var errorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        updateErrorViewCornerRadius()
        updateErrorViewHiddenStatus()
    }
    
    
    
}
