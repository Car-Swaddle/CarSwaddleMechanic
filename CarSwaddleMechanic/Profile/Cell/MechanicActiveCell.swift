//
//  ActivityCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleStore


final class MechanicActiveCell: UITableViewCell, NibRegisterable {

    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var detailSwitchViewWrapper: DetailSwitchViewWrapper!
    
    private var detailSwitchView: DetailSwitchView {
        return detailSwitchViewWrapper.view
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateChargeForTravel()
        detailSwitchView.titleText = NSLocalizedString("Allow new appointments", comment: "")
        detailSwitchView.detailText = NSLocalizedString("If this is on, customers can schedule appointments on your calendar", comment: "Explanation of a UI switch")
        
        detailSwitchView.switchDidChangeValue = { [weak self] newValue in
            guard let self = self else { return }
            self.switchDidChange(self.detailSwitchView.valueSwitch)
        }
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateChargeForTravel()
    }
    
    private func updateChargeForTravel() {
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getCurrentMechanic(in: context) { mechanicID, error in
                store.mainContext { mainContext in
                    guard let mechanicID = mechanicID,
                        let mechanic = mainContext.object(with: mechanicID) as? Mechanic else { return }
                    self?.detailSwitchView.valueSwitch.setOn(mechanic.isActive, animated: false)
                }
            }
        }
    }

    private func switchDidChange(_ activeSwitch: UISwitch) {
        let isActive = activeSwitch.isOn
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: isActive, token: nil, dateOfBirth: nil, address: nil, in: context) { mechanicID, error in
                DispatchQueue.main.async {
                    if error == nil {
                    } else {
                        self?.detailSwitchView.valueSwitch.setOn(!isActive, animated: true)
                    }
                }
            }
        }
    }
    
}
