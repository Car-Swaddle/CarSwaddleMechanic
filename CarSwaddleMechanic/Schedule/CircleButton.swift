//
//  CircleButton.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/19/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


private let inset: CGFloat = 7

@IBDesignable
class CircleButton: UIButton {
    
//    @IBInspectable var buttonImage: UIImage? {
//        didSet {
//            setImage(buttonImage, for: .normal)
//        }
//    }
    
    @IBInspectable var buttonColor: UIColor = UIColor.gray4 {
        didSet {
            updateBorderColor()
            tintColor = buttonColor
        }
    }
    
//    @IBInspectable var borderWidth: CGFloat = 1.0 {
//        didSet {
//            updateBorderWidth()
//        }
//    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height/2
    }
    
    private func setup() {
        updateBorderColor()
        updateBorderWidth()
        
        
        contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    private func updateBorderColor() {
        layer.borderColor = buttonColor.cgColor
    }
    
    private func updateBorderWidth() {
        layer.borderWidth = 1
    }
    
}
