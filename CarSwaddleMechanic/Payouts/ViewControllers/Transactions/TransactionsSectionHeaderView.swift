//
//  TransactionsSectionHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/28/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI


final class TransactionsSectionHeaderView: UIView, NibInstantiating {
    
    var availableDate: Date? {
        didSet {
            updateTitleLabel()
        }
    }
    
    private func updateTitleLabel() {
        labeledBanner.label.text = titleLabelText
    }
    
    private var titleLabelText: String {
        guard let date = availableDate else {
            return NSLocalizedString("Deposit date", comment: "Transaction availability date")
        }
        let formatString = NSLocalizedString("Deposit date %@", comment: "Date a transaction will be available")
        return String(format: formatString, monthDayDateFormatter.string(from: date))
    }
    
    @IBOutlet private weak var labeledBanner: LabeledBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addHairlineView(toSide: .top, color: .separator)
        addHairlineView(toSide: .bottom, color: .separator)
        
//        layer.shadowColor = UIColor.gray3.cgColor
        layer.shadowOpacity = 0.05
//        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
}




extension UIView {
    
    @IBInspectable
    var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let shadowColor = layer.shadowColor {
                return UIColor(cgColor: shadowColor)
            } else {
                return nil
            }
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            } else {
                return nil
            }
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
}
