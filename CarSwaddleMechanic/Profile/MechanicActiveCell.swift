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
    
    private lazy var activeSwitch: UISwitch = {
        let activitySwitch = UISwitch()
        activitySwitch.addTarget(self, action: #selector(MechanicActiveCell.switchDidChange(_:)), for: .valueChanged)
        return activitySwitch
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = activeSwitch
        updateIsActive()
        textLabel?.text = NSLocalizedString("Active", comment: "")
        detailTextLabel?.text = NSLocalizedString("If this is on, people will schedule appointments on your calendar", comment: "Explanation of a UI switch")
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
                    self?.activeSwitch.isOn = mechanic.isActive
                }
            }
        }
    }

    @objc private func switchDidChange(_ activeSwitch: UISwitch) {
        let isActive = activeSwitch.isOn
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: isActive, token: nil, in: context) { mechanicID, error in
                DispatchQueue.main.async {
                    if error == nil {
                    } else {
                        self?.activeSwitch.isOn = !isActive
                    }
                }
            }
        }
    }
    
}
