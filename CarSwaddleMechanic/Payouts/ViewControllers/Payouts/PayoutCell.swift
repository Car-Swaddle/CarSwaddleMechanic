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
        statusLabel.text = payout.payoutStatus.localizedString
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


public extension Payout {
    
    public var payoutStatus: PayoutStatus {
        switch status {
        case PayoutStatus.inTransit.rawValue: return .inTransit
        case PayoutStatus.paid.rawValue: return .paid
        case PayoutStatus.pending.rawValue: return .pending
        case PayoutStatus.canceled.rawValue: return .canceled
        case PayoutStatus.failed.rawValue: return .failed
        default: return .pending
        }
    }
    
    public enum PayoutStatus: String {
        case inTransit = "in_transit"
        case paid
        case pending
        case canceled
        case failed
        
        public var localizedString: String {
            switch self {
            case .inTransit:
                return NSLocalizedString("In transit", comment: "Localized string for payout status")
            case .paid:
                return NSLocalizedString("Paid", comment: "Localized string for payout status")
            case .pending:
                return NSLocalizedString("Pending", comment: "Localized string for payout status")
            case .canceled:
                return NSLocalizedString("Canceled", comment: "Localized string for payout status")
            case .failed:
                return NSLocalizedString("Failed", comment: "Localized string for payout status")
            }
        }
        
    }
    
}
