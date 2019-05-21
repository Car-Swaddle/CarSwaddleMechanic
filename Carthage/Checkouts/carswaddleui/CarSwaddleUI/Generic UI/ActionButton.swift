//
//  ActionButton.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/11/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public let defaultCornerRadius: CGFloat = 22

private let insetLength: CGFloat = 12

open class ActionButton: LoadingButton {
    
    @objc dynamic public var defaultTitleFont: UIFont = UIFont.appFont(type: .system, size: 17) {
        didSet {
            updateTitleFont()
        }
    }
    @objc dynamic public var defaultBackgroundColor: UIColor = .white {
        didSet {
            updateBackgroundColor()
        }
    }
    
    @objc dynamic public var disabledBackgroundColor: UIColor = .gray {
        didSet {
            updateBackgroundColor()
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 1, height: 2)
        updateBackgroundColor()
        setTitleColor(.white, for: .normal)
        updateTitleFont()
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: insetLength, left: insetLength, bottom: insetLength, right: insetLength)
        
        indicatorViewStyle = .white
    }
    
    private var backgroundColorForCurrentState: UIColor {
        return isEnabled ? defaultBackgroundColor : disabledBackgroundColor
    }
    
    private func updateBackgroundColor() {
        backgroundColor = backgroundColorForCurrentState
    }
    
    private func updateTitleFont() {
        titleLabel?.font = defaultTitleFont
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(width: max(size.width + (insetLength*2), 160), height: size.height + insetLength)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
}
