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

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

final class BalanceAmountView: UIView, NibInstantiating {
    
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var inTransitLabel: UILabel!
    
    @IBOutlet private weak var inTransitTextLabel: UILabel!
    
    var inTransitAmount: Int? {
        didSet {
            inTransitLabel.text = currencyFormatter.string(from: inTransitAmount?.dollarValue ?? 0)
        }
    }
    
    func configure(with amount: Amount, amountType: Balance.AmountType) {
        amountLabel.text = currencyFormatter.string(from: amount.totalDollarValue)
        descriptionLabel.text = self.text(from: amountType)
    }
    
    func configureForEmpty() {
        amountLabel.text = NSLocalizedString("--", comment: "Represent an empty state")
        descriptionLabel.text = NSLocalizedString("balance", comment: "Represent an empty state")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inTransitLabel.text = "--"
        inTransitTextLabel.text = NSLocalizedString("In transit", comment: "Label text with a label above indicating how much money is in transit")
        
        amountLabel.font = UIFont.appFont(type: .regular, size: 64)
        descriptionLabel.font = UIFont.appFont(type: .regular, size: 15)
        inTransitLabel.font = UIFont.appFont(type: .medium, size: 17)
        inTransitTextLabel.font = UIFont.appFont(type: .regular, size: 15)
    }
    
    private func text(from type: Balance.AmountType) -> String {
        switch type {
        case .available: return NSLocalizedString("Available balance", comment: "label under dollar value")
        case .pending: return NSLocalizedString("Car Swaddle Account Balance", comment: "label under dollar value")
        case .reserved: return NSLocalizedString("Reserved balance", comment: "label under dollar value")
        }
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


