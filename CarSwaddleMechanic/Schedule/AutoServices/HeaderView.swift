//
//  HeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import UIKit

final class HeaderView: UIView {
    
    @IBInspectable public var labelText: String? {
        didSet {
            labeledBanner.label.text = labelText
        }
    }
    
    @IBInspectable public var height: CGFloat = 44 {
        didSet {
            heightConstraint?.constant = height
        }
    }
    
    @IBInspectable public var minimumWidth: CGFloat = 100 {
        didSet {
            widthConstraint?.constant = minimumWidth
        }
    }
    
    private lazy var labeledBanner: LabeledBannerView = {
        let labeledBanner = LabeledBannerView()
        labeledBanner.translatesAutoresizingMaskIntoConstraints = false
        labeledBanner.backgroundColor = .secondary
        return labeledBanner
    }()
    
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        
//        addHairlineView(toSide: .bottom, color: .gray3)
        
        addSubview(labeledBanner)
        
        labeledBanner.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        labeledBanner.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
//        labeledBanner.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: 8).isActive = true
        labeledBanner.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8).isActive = true
        
        let width = labeledBanner.widthAnchor.constraint(equalToConstant: minimumWidth)
        width.priority = UILayoutPriority(rawValue: 600)
        width.isActive = true
        
        self.widthConstraint = width
        
        let heightConstraint = labeledBanner.heightAnchor.constraint(equalToConstant: 44)
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint
    }
    
}
