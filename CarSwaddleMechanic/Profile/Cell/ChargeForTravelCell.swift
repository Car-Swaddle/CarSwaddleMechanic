//
//  ChargeForTravelCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/29/20.
//  Copyright © 2020 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleStore


class ChargeForTravelCell: UITableViewCell, NibRegisterable {
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var detailSwitchViewWrapper: DetailSwitchViewWrapper!
    
    private var detailSwitchView: DetailSwitchView {
        return detailSwitchViewWrapper.view
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailSwitchView.titleText = NSLocalizedString("Charge for travel", comment: "If the mechanic will charge for how far the mechanic has to travel to the customer.")
        detailSwitchView.detailText = NSLocalizedString("If this is on, you will charge the normal price for travel. If you turn this off, you will not be covered for your travel costs. Use this to offer a discount to your customers", comment: "Explanation of a UI switch")
        
        detailSwitchView.switchDidChangeValue = { [weak self] newValue in
            guard let self = self else { return }
            self.switchDidChange(self.detailSwitchView.valueSwitch)
        }
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateIsActive()
    }
    
    private func updateIsActive() {
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getCurrentMechanic(in: context) { mechanicID, error in
                store.mainContext { mainContext in
                    guard let mechanicID = mechanicID,
                        let mechanic = mainContext.object(with: mechanicID) as? Mechanic else { return }
                    self?.detailSwitchView.valueSwitch.setOn(mechanic.chargeForTravel, animated: false)
                }
            }
        }
    }

    private func switchDidChange(_ activeSwitch: UISwitch) {
        let chargeForTravel = activeSwitch.isOn
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(chargeForTravel: chargeForTravel, in: context) { mechanicID, error in
                DispatchQueue.main.async {
                    if error == nil {
                    } else {
                        self?.detailSwitchView.valueSwitch.setOn(!chargeForTravel, animated: true)
                    }
                }
            }
        }
    }
    
    
}
