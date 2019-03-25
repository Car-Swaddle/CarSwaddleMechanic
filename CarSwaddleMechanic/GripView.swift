//
//  GripView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/19/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI

class GripView: UIView, NibInstantiating {
    
    var lineWidth: CGFloat = 2 {
        didSet {
            widthConstraints.forEach { $0.constant = lineWidth }
        }
    }
    
//    @IBOutlet weak var widthConstraints: NSLayoutConstraint!
    
    @IBOutlet var widthConstraints: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lineWidth = 1
        
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
}
