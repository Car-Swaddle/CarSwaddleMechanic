//
//  ReviewListCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store
import Cosmos


let monthDayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"
    return dateFormatter
}()


final class ReviewListCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var cosmosView: CosmosView!
    @IBOutlet private weak var reviewerNameLabel: UILabel!
    @IBOutlet private weak var reviewTextLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cosmosView.isUserInteractionEnabled = false
        selectionStyle = .none
    }
    
    func configure(with review: Review) {
        cosmosView.rating = Double(review.rating)
        reviewerNameLabel.text = review.user?.firstName
        reviewTextLabel.text = review.text
        dateLabel.text = monthDayDateFormatter.string(from: review.creationDate)
    }
    
}
