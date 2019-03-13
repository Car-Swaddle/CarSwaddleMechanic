//
//  ActionButton.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/11/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

private let insetLength: CGFloat = 6

open class ActionButton: UIButton {
    
    // Change this sometime. Subclass UIControl and make a sublabel and label
    var actionTitle: String? {
        didSet {
            updateTitle()
        }
    }
    
    // Change this sometime. Subclass UIControl and make a sublabel and label
    var actionSubtext: String? {
        didSet {
            updateTitle()
        }
    }
    
    // Change this sometime. Subclass UIControl and make a sublabel and label
    private func updateTitle() {
        
        let attributedTitle = NSMutableAttributedString(string: "")
        
        if let actionSubtext = actionSubtext {
            let attributedSubtext = NSAttributedString(string: actionSubtext, attributes: [.font: UIFont.appFont(type: .semiBold, size: 15)])
            attributedTitle.append(attributedSubtext)
        }
        
        attributedTitle.append(NSAttributedString(string: "\n"))
        
        if let actionTitle = actionTitle {
            let attributedAction = NSAttributedString(string: actionTitle, attributes: [.font: UIFont.appFont(type: .semiBold, size: 20)])
            attributedTitle.append(attributedAction)
        }
        
        self.setAttributedTitle(attributedTitle, for: .normal)
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
        backgroundColor = .secondary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.appFont(type: .semiBold, size: 20)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
//        titleEdgeInsets = UIEdgeInsets(top: insetLength, left: insetLength, bottom: insetLength, right: insetLength)
        contentEdgeInsets = UIEdgeInsets(top: insetLength, left: insetLength, bottom: insetLength, right: insetLength)
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(width: max(size.width + (insetLength*2), 160), height: size.height + insetLength)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    
    func adjustInsets(for tableView: UITableView) {
        let previous = tableView.contentInset
        tableView.contentInset = UIEdgeInsets(top: previous.top, left: previous.left, bottom: frame.height, right: previous.right)
    }
    
}



