//
//  PhoneNumberVerificationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI

final class PhoneNumberVerificationCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var verifiedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func didTapVerify() {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
