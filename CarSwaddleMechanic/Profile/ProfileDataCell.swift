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

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
