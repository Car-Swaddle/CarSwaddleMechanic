//
//  AutoServiceStatusCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleStore
import CarSwaddleData


private let normalFont = UIFont.systemFont(ofSize: 15)
private let boldFont = UIFont.boldSystemFont(ofSize: 15)

final class AutoServiceStatusCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var scheduledButton: UIButton!
    @IBOutlet private weak var inProgressButton: UIButton!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var canceledButton: UIButton!
    
    private var autoServiceID: String?
    
    lazy private var buttons: [UIButton] = [scheduledButton, inProgressButton, completedButton, canceledButton]
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func configure(with autoService: AutoService) {
        setButtonSelected(self.button(for: autoService.status))
        autoServiceID = autoService.identifier
    }
    
    private func setButtonSelected(_ button: UIButton) {
        resetAllButtonsStyle()
        button.titleLabel?.font = boldFont
        button.layer.cornerRadius = defaultCornerRadius
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
    }
    
    private func resetAllButtonsStyle() {
        for button in buttons {
            button.titleLabel?.font = normalFont
            button.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func button(for status: AutoService.Status) -> UIButton {
        switch status {
        case .canceled: return canceledButton
        case .completed: return completedButton
        case .inProgress: return inProgressButton
        case .scheduled: return scheduledButton
        }
    }
    
    private func status(for button: UIButton) -> AutoService.Status {
        switch button {
        case scheduledButton: return .scheduled
        case inProgressButton: return .inProgress
        case completedButton: return .completed
        case canceledButton: return .canceled
        default: fatalError("Add that button!")
        }
    }
    
    @IBAction private func didSelectButton(_ button: UIButton) {
        setButtonSelected(button)
        guard let serviceID = autoServiceID else { return }
        let newStatus = self.status(for: button)
        store.privateContext { [weak self] context in
            self?.autoServiceNetwork.updateAutoService(autoServiceID: serviceID, status: newStatus, in: context) { objectID, error in
                print("object")
            }
        }
    }
    
}
