//
//  TweakStringValueCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/27/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

final class TweakStringValueCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var labelLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func configure(with tweak: Tweak) {
        labelLabel.text = tweak.label
        if let value = tweak.value {
            if let intValue = value as? Int {
                valueLabel.text = String(intValue)
            } else if let stringValue = value as? String {
                valueLabel.text = stringValue
            }
        } else {
            valueLabel.text = nil
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
