//
//  AddReceiptCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI

final class AddReceiptCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = NSLocalizedString("Add Receipt", comment: "Tap to add a transaction receipt")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
