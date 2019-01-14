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

final class EarningsHeaderView: UIView, NibInstantiating {
    
    @IBOutlet private weak var balanceAmountViewWrapper: BalanceAmountViewWrapper!
    private var balanceAmountView: BalanceAmountView { return balanceAmountViewWrapper.view }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with balance: Balance) {
        balanceAmountView.configure(with: balance.pending, amountType: .pending)
    }
    
    func configureForEmpty() {
        balanceAmountView.configureForEmpty()
    }
    
}

extension Balance {
    
    enum AmountType {
        case pending
        case available
        case reserved
    }
    
}


