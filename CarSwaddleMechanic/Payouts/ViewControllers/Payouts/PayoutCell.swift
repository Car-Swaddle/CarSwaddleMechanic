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

    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var payoutDescriptionLabel: UILabel!
    
    
    func configure(with payout: Payout) {
        amountLabel.text = currencyFormatter.string(from: payout.amount.dollarValue)
        currencyLabel.text = payout.currency
        dateLabel.text = monthDayYearDateFormatter.string(from: payout.arrivalDate)
        statusLabel.text = payout.status.localizedString
        payoutDescriptionLabel.text = payout.payoutDescription
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
