//
//  ProfileServiceRegionCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

class ProfileServiceRegionCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label?.text = NSLocalizedString("Set service region", comment: "Service region cell")
        accessoryType = .disclosureIndicator
        label?.font = UIFont.appFont(type: .regular, size: 17)
    }
    
    
    func configure(with region: Region) {
        
    }
    
}
