//
//  PayoutCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store

final class PayoutCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var payoutDescriptionLabel: UILabel!
    @IBOutlet private weak var errorDescriptionLabel: UILabel!
    
    func configure(with payout: Payout) {
        amountLabel.text = currencyFormatter.string(from: payout.amount.dollarValue)
        dateLabel.text = monthDayYearDateFormatter.string(from: payout.arrivalDate)
        statusLabel.text = payout.status.localizedString
        payoutDescriptionLabel.text = payout.payoutDescription
        if let failurMessage = payout.failureMessage, !failurMessage.isEmpty {
            errorDescriptionLabel.text = payout.failureMessage
            errorDescriptionLabel.isHiddenInStackView = false
        } else {
            errorDescriptionLabel.isHiddenInStackView = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amountLabel.font = UIFont.appFont(type: .semiBold, size: 20)
        payoutDescriptionLabel.font = UIFont.appFont(type: .regular, size: 17)
        errorDescriptionLabel.font = UIFont.appFont(type: .regular, size: 17)
        dateLabel.font = UIFont.appFont(type: .regular, size: 15)
        statusLabel.font = UIFont.appFont(type: .regular, size: 15)
    }
    
}
