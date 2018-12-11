//
//  AutoServiceCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d h:mm a"
    return formatter
}()

final class AutoServiceCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var scheduledDateLabel: UILabel!
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var vehicleLabel: UILabel!
    @IBOutlet private weak var serviceTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scheduledDateLabel.text = ""
        userLabel.text = ""
        locationLabel.text = ""
        vehicleLabel.text = ""
        serviceTypeLabel.text = ""
    }
    
    func configure(with autoService: AutoService) {
        if let date = autoService.scheduledDate {
            scheduledDateLabel.text = dateFormatter.string(from: date)
        }
        
        userLabel.text = autoService.creator?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
        vehicleLabel.text = autoService.vehicle?.name
        serviceTypeLabel.text = autoService.serviceEntities.first?.entityType.localizedString
    }
    
}


extension ServiceEntity.EntityType {
    
    var localizedString: String {
        switch self {
        case .oilChange:
            return NSLocalizedString("Oil Change", comment: "Type of oil change")
        }
    }
    
}
