//
//  TransactionCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d"
    return formatter
}()


protocol TransactionCellDelegate: AnyObject {
    func didUpdateHeight(cell: TransactionCell)
}

final class TransactionCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    weak var delegate: TransactionCellDelegate?
    
    func configure(with transaction: Transaction) {
        let topTextFormatString = NSLocalizedString("%@ • %@", comment: "date and payment type")
        dateLabel.text = String(format: topTextFormatString, monthDayYearDateFormatter.string(from: transaction.created), transaction.transactionType.localizedString)
//        typeLabel.text = transaction.transactionType.localizedString
        let transactionAmount = transaction.amount
        valueLabel.text = currencyFormatter.string(from: transactionAmount.dollarValue)
        
        typeLabel.isHiddenInStackView = true
        
        if transactionAmount > 0 {
            valueLabel.textColor = .green1
        } else {
            valueLabel.textColor = .black
        }
        
        if let transactionDescription = transaction.transactionDescription, !transactionDescription.isEmpty {
            descriptionLabel.text = transaction.transactionDescription
            descriptionLabel.isHiddenInStackView = false
        } else {
            descriptionLabel.isHiddenInStackView = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel.font = UIFont.appFont(type: .regular, size: 15)
        typeLabel.font = UIFont.appFont(type: .regular, size: 15)
//        valueLabel.font = UIFont.appFont(type: .medium, size: 20)
        descriptionLabel.font = UIFont.appFont(type: .medium, size: 17)
        
//        let mono = UIFontDescriptor(name: "Montserrat", size: 20).monospacedDigitFontDescriptor
//        valueLabel.font = UIFont(descriptor: mono, size: 0)
        valueLabel.font = UIFont.appFont(type: .monoSpaced, size: 20)
    }
    
}




extension Transaction.TransactionType {
    
    var localizedString: String {
        switch self {
        case .adjustment: return NSLocalizedString("Adjustment", comment: "Transaction Type string")
        case .advance: return NSLocalizedString("Advance", comment: "Transaction Type string")
        case .advanceFunding: return NSLocalizedString("Advance Funding", comment: "Transaction Type string")
        case .applicationFee: return NSLocalizedString("Application Fee", comment: "Transaction Type string")
        case .applicationFeeRefund: return NSLocalizedString("Application Fee Refund", comment: "Transaction Type string")
        case .charge: return NSLocalizedString("Charge", comment: "Transaction Type string")
        case .connectCollectionTransfer: return NSLocalizedString("Connect Collection Transfer", comment: "Transaction Type string")
        case .issuingAuthorizationHold: return NSLocalizedString("Issuing Authorization Hold", comment: "Transaction Type string")
        case .issuingAuthorizationRelease: return NSLocalizedString("Issuing Authorization Release", comment: "Transaction Type string")
        case .issuingTransaction: return NSLocalizedString("Issuing Transaction", comment: "Transaction Type string")
        case .payment: return NSLocalizedString("Payment", comment: "Transaction Type string")
        case .paymentFailureRefund: return NSLocalizedString("Payment Failure Refund", comment: "Transaction Type string")
        case .paymentRefund: return NSLocalizedString("Payment Refund", comment: "Transaction Type string")
        case .payout: return NSLocalizedString("Deposit", comment: "Transaction Type string")
        case .payoutCancel: return NSLocalizedString("Deposit Cancel", comment: "Transaction Type string")
        case .payoutFailure: return NSLocalizedString("Deposit Failure", comment: "Transaction Type string")
        case .refund: return NSLocalizedString("Refund", comment: "Transaction Type string")
        case .refundFailure: return NSLocalizedString("Refund Failure", comment: "Transaction Type string")
        case .reserveTransaction: return NSLocalizedString("Reserve Transaction", comment: "Transaction Type string")
        case .reservedFunds: return NSLocalizedString("Reserved Funds", comment: "Transaction Type string")
        case .stripeFee: return NSLocalizedString("Stripe Fee", comment: "Transaction Type string")
        case .stripeFxFee: return NSLocalizedString("Stripe Fx Fee", comment: "Transaction Type string")
        case .taxFee: return NSLocalizedString("Tax Fee", comment: "Transaction Type string")
        case .topup: return NSLocalizedString("Topup", comment: "Transaction Type string")
        case .topupReversal: return NSLocalizedString("Topup Reversal", comment: "Transaction Type string")
        case .transfer: return NSLocalizedString("Transfer", comment: "Transaction Type string")
        case .transferCancel: return NSLocalizedString("Transfer Cancel", comment: "Transaction Type string")
        case .transferFailure: return NSLocalizedString("Transfer Failure", comment: "Transaction Type string")
        case .transferRefund: return NSLocalizedString("Transfer Refund", comment: "Transaction Type string")
        }
    }
    
}
