//
//  ProfileHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleUI

protocol ProfileHeaderViewDelegate: AnyObject {
    func didSelectCamera(headerView: ProfileHeaderView)
    func didSelectCameraRoll(headerView: ProfileHeaderView)
    func presentAlert(alert: UIAlertController, headerView: ProfileHeaderView)
}

final class ProfileHeaderView: UIView, NibInstantiating {
    
    public func configure(with mechanic: Mechanic) {
        mechanicImageView.configure(withMechanicID: mechanic.identifier)
    }
    
    public weak var delegate: ProfileHeaderViewDelegate?
    
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var mechanicImageView: MechanicImageView!
    
    @IBAction private func didSelectEditButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addCancelAction()
        
        delegate?.presentAlert(alert: alert, headerView: self)
    }
    
    
    private var cameraAction: UIAlertAction {
        let title = NSLocalizedString("Camera", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            self.delegate?.didSelectCamera(headerView: self)
        }
    }
    
    private var cameraRollAction: UIAlertAction {
        let title = NSLocalizedString("Camera Roll", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            self.delegate?.didSelectCameraRoll(headerView: self)
        }
    }
    
}
