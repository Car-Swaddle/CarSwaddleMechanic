//
//  CancelAutoServiceCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI

final class CancelAutoServiceCell: UITableViewCell, NibRegisterable {

    @IBOutlet weak var cancelAutoServiceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cancelAutoServiceLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        selectionStyle = .none
    }
    
}
