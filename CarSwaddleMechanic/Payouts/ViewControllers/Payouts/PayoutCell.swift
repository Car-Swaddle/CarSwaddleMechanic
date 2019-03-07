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
        
//        dateLabel.text = monthDayYearDateFormatter.string(from: payout.arrivalDate)
        
        let topTextFormatString = NSLocalizedString("%@ • %@", comment: "date and payment type")
        dateLabel.text = String(format: topTextFormatString, monthDayYearDateFormatter.string(from: payout.arrivalDate), payout.status.localizedString)
        
//        statusLabel.text = payout.status.localizedString
        payoutDescriptionLabel.text = payout.payoutDescription
        
        if let failurMessage = payout.failureMessage, !failurMessage.isEmpty {
            errorDescriptionLabel.text = payout.failureMessage
            errorDescriptionLabel.isHiddenInStackView = false
        } else {
            errorDescriptionLabel.isHiddenInStackView = true
        }
        
        if payout.amount > 0 {
            amountLabel.textColor = .green1
        } else {
            amountLabel.textColor = .black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amountLabel.font = UIFont.appFont(type: .medium, size: 20)
        payoutDescriptionLabel.font = UIFont.appFont(type: .medium, size: 17)
        errorDescriptionLabel.font = UIFont.appFont(type: .medium, size: 17)
        dateLabel.font = UIFont.appFont(type: .regular, size: 15)
        statusLabel.font = UIFont.appFont(type: .regular, size: 15)
        
        amountLabel.font = UIFont.appFont(type: .monoSpaced, size: 20)
    }
    
}
