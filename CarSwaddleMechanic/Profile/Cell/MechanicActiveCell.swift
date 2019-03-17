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
import Store


final class MechanicActiveCell: UITableViewCell, NibRegisterable {

    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var subLabel: UILabel!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activeSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        accessoryView = activeSwitch
        updateIsActive()
        label.font = UIFont.appFont(type: .regular, size: 17)
        subLabel.font = UIFont.appFont(type: .regular, size: 15)
        label.text = NSLocalizedString("Allow new appointments", comment: "")
        subLabel?.text = NSLocalizedString("If this is on, customers can schedule appointments on your calendar", comment: "Explanation of a UI switch")
        
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
                    self?.activeSwitch.setOn(mechanic.isActive, animated: false)
                }
            }
        }
    }

    @IBAction private func switchDidChange(_ activeSwitch: UISwitch) {
        let isActive = activeSwitch.isOn
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: isActive, token: nil, dateOfBirth: nil, address: nil, in: context) { mechanicID, error in
                DispatchQueue.main.async {
                    if error == nil {
                    } else {
                        self?.activeSwitch.setOn(!isActive, animated: true)
                    }
                }
            }
        }
    }
    
}
