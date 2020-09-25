//
//  AutoServiceVehicleCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/21/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleStore
import UIKit

final class AutoServiceVehicleCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var vehicleNameLabel: UILabel!
    @IBOutlet private weak var oilTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        vehicleNameLabel.font = UIFont.appFont(type: .regular, size: 17)
        oilTypeLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        let view = addHairlineView(toSide: .bottom, color: .gray3, size: 1.0, insets: insets)
        view.layer.cornerRadius = 0.5
        
        selectionStyle = .none
    }
    
    func configure(with autoService: AutoService) {
        vehicleNameLabel.text = autoService.vehicle?.localizedDescription
        oilTypeLabel.text = self.localizedStringForOilType(for: autoService)
    }
    
    private func localizedStringForOilType(for autoService: AutoService) -> String? {
        guard let oilType = autoService.firstOilChange?.oilType else {
            return nil
        }
        switch oilType {
        case .blend:
            return NSLocalizedString("Blend Oil Type", comment: "Oil Type")
        case .conventional:
            return NSLocalizedString("Conventional Oil Type", comment: "Oil Type")
        case .synthetic:
            return NSLocalizedString("Synthetic Oil Type", comment: "Oil Type")
        case .highMileage:
            return NSLocalizedString("High Mileage Oil Type", comment: "Oil Type")
        }
    }
    
}
