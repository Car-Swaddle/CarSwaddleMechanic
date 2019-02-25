//
//  AutoServiceItemCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class AutoServiceItemCell: UITableViewCell, NibRegisterable {

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    var subtitleText: String? {
        didSet {
            subtitleLabel.text = subtitleText
            subtitleLabel.isHidden = subtitleText == nil
        }
    }
    
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        selectionStyle = .none
    }
    
}
