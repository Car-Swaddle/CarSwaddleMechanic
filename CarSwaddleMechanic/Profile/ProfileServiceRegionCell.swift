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

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = NSLocalizedString("Service Region", comment: "Service region cell")
    }
    
    func configure(with region: Region) {
        
    }
    
}
