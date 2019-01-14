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


final class TransactionCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var netLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    
    func configure(with transaction: Transaction) {
        netLabel.text = currencyFormatter.string(from: transaction.net.dollarValue)
        feeLabel.text = currencyFormatter.string(from: transaction.fee.dollarValue)
        totalLabel.text = currencyFormatter.string(from: transaction.amount.dollarValue)
        dateLabel.text = monthDayYearDateFormatter.string(from: transaction.created)
        statusLabel.text = transaction.status.localizedString
        
        bottomView.isHiddenInStackView = transaction.fee == 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}


public extension Transaction.Status {
    
    public var localizedString: String {
        switch self {
        case .pending:
            return NSLocalizedString("Pending", comment: "Status of a transaction")
        case .available:
            return NSLocalizedString("Available", comment: "Status of a transaction")
        }
    }
    
}
