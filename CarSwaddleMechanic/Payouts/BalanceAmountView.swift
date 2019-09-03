//
//  EarningsHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

extension String {
    public static let blankText = NSLocalizedString("--", comment: "Represent an empty state")
}

private let inTransitString = NSLocalizedString("Transferring", comment: "Label text with a label above indicating how much money is in transit")
private let accountBalanceString = NSLocalizedString("Account balance", comment: "Label text with a label above indicating how much money is in transit")
private let accountBalanceSubstring = NSLocalizedString("(2 day rolling deposit)", comment: "Label text with a label above indicating how much money is in transit")
private let processingString = NSLocalizedString("Processing", comment: "Label text with a label above indicating how much money is in transit")

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

final class BalanceAmountView: UIView, NibInstantiating {
    
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var availableLabel: UILabel!
    @IBOutlet private weak var inTransitLabel: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var inTransitTextLabel: UILabel!
    @IBOutlet private weak var availableTextLabel: UILabel!
    
    @IBOutlet private weak var descriptionSubtitleLabel: UILabel!
    
    var inTransitAmount: Int? {
        didSet {
            inTransitLabel.text = currencyFormatter.string(from: inTransitAmount?.dollarValue ?? 0)
        }
    }
    
    var availableAmount: Int? {
        didSet {
            guard let availableAmount = availableAmount else {
                amountLabel.text = .blankText
                return
            }
            amountLabel.text = currencyFormatter.string(from: availableAmount.dollarValue)
        }
    }
    
    var pendingAmount: Int? {
        didSet {
            guard let pendingAmount = pendingAmount else {
                availableLabel.text = .blankText
                return
            }
            availableLabel.text = currencyFormatter.string(from: pendingAmount.dollarValue)
        }
    }
    
    func configureForEmpty() {
        pendingAmount = nil
        availableAmount = nil
        inTransitAmount = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        inTransitLabel.text = .blankText
        amountLabel.text = .blankText
        availableLabel.text = .blankText
        
        inTransitTextLabel.text = inTransitString
        descriptionSubtitleLabel.text = accountBalanceSubstring
        descriptionLabel.text = accountBalanceString
        availableTextLabel.text = processingString
        
        amountLabel.font = UIFont.appFont(type: .regular, size: 64)
        descriptionLabel.font = UIFont.appFont(type: .regular, size: 15)
        descriptionSubtitleLabel.font = UIFont.appFont(type: .regular, size: 15)
        inTransitLabel.font = UIFont.appFont(type: .medium, size: 17)
        inTransitTextLabel.font = UIFont.appFont(type: .regular, size: 15)
        availableLabel.font = UIFont.appFont(type: .medium, size: 17)
        availableTextLabel.font = UIFont.appFont(type: .regular, size: 15)
    }
    
}


final class BalanceAmountViewWrapper: UIView {
    
    let view: BalanceAmountView = BalanceAmountView.viewFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        addSubview(view)
        view.pinFrameToSuperViewBounds()
    }
    
}


