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
        
        addHairlineView(toSide: .top, color: .gray3)
        addHairlineView(toSide: .bottom, color: .gray3)
        
//        layer.shadowColor = UIColor.gray3.cgColor
        layer.shadowOpacity = 0.05
//        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
}
