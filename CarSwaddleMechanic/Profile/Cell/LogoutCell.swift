//
//  LogoutCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/30/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import UIKit

final class LogoutCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var logoutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoutLabel.font = UIFont.appFont(type: .semiBold, size: 17)
    }
    
}
