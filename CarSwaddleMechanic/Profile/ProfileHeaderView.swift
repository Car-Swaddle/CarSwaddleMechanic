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
import Cosmos
import CarSwaddleData

let ratingFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.minimumSignificantDigits = 2
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.maximumIntegerDigits = 1
    
    return numberFormatter
}()

private let formatServicesString = NSLocalizedString("%i services completed", comment: "Auto services provided.")
private let formatAveragesString = NSLocalizedString("%@ avg. from %i ratings", comment: "Ratings report")

protocol ProfileHeaderViewDelegate: AnyObject {
    func didSelectCamera(headerView: ProfileHeaderView)
    func didSelectCameraRoll(headerView: ProfileHeaderView)
    func didSelectEditName(headerView: ProfileHeaderView)
    func presentAlert(alert: UIAlertController, headerView: ProfileHeaderView)
}

final class ProfileHeaderView: UIView, NibInstantiating {
    
    public func configure(with mechanic: Mechanic) {
        mechanicImageView.configure(withMechanicID: mechanic.identifier)
        self.nameLabel.text = mechanic.user?.displayName
        let mechanicID = mechanic.identifier
        configure(with: mechanic.stats)
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.getStats(mechanicID: mechanicID, in: privateContext) { mechanicObjectID, error in
                store.mainContext { mainContext in
                    guard let self = self,
                        let mechanicObjectID = mechanicObjectID,
                        let mechanic = mainContext.object(with: mechanicObjectID) as? Mechanic,
                        let stats = mechanic.stats else { return }
                    self.configure(with: stats)
                }
            }
        }
    }
    
    public weak var delegate: ProfileHeaderViewDelegate?
    
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var mechanicImageView: MechanicImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var starRatingView: CosmosView!
    @IBOutlet private weak var ratingsLabel: UILabel!
    @IBOutlet private weak var servicesProvidedLabel: UILabel!
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    @IBAction private func didSelectEditButton() {
        let editAlert = self.editAlert()
        delegate?.presentAlert(alert: editAlert, headerView: self)
    }
    
    private func cameraAlertController() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addCancelAction()
        
        return alert
    }
    
    private func editAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(editProfilePictureAction)
        alert.addAction(editNameAction)
        alert.addCancelAction()
        
        return alert
    }
    
    private func configure(with stats: Stats?) {
        if let stats = stats {
            configure(with: stats)
        } else {
            configureForEmpty()
        }
    }
    
    private func configure(with stats: Stats) {
        let averageRating = stats.averageRating
        self.starRatingView.rating = averageRating
        
        let numberOfRatings = stats.numberOfRatings
        let averageRatingString = ratingFormatter.string(from: NSNumber(value: averageRating)) ?? ""
        ratingsLabel.text = String(format: formatAveragesString, averageRatingString, numberOfRatings)
        
        servicesProvidedLabel.text = String(format: formatServicesString, stats.autoServicesProvided)
    }
    
    private func configureForEmpty() {
        let averageRating = 0.0
        self.starRatingView.rating = averageRating
        
        let numberOfRatings = 0
        let averageRatingString = ratingFormatter.string(from: NSNumber(value: averageRating)) ?? ""
        ratingsLabel.text = String(format: formatAveragesString, averageRatingString, numberOfRatings)
        
        let autoServicesProvided = 0
        servicesProvidedLabel.text = String(format: formatServicesString, autoServicesProvided)
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
    
    private var editProfilePictureAction: UIAlertAction {
        let title = NSLocalizedString("Edit Profile Picture", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            let alert = self.cameraAlertController()
            self.delegate?.presentAlert(alert: alert, headerView: self)
        }
    }
    
    private var editNameAction: UIAlertAction {
        let title = NSLocalizedString("Edit Name", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { action in
            self.delegate?.didSelectEditName(headerView: self)
        }
    }
    
}
