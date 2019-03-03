//
//  IdentificationInfoViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import Stripe

final class IdentificationInfoViewController: UIViewController, StoryboardInstantiating {

    public var isFullSocialSecurityNumberRequired: Bool = false {
        didSet {
            guard viewIfLoaded != nil else { return }
            updatePlaceholderText()
        }
    }
    
    @IBOutlet private weak var socialSecurityTextField: UITextField!
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlaceholderText()
    }
    
    @IBAction private func didTapSave() {
        guard let socialSecurityNumber = socialSecurityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if isFullSocialSecurityNumberRequired == false && socialSecurityNumber.count != 4 {
            let title = NSLocalizedString("Should enter last 4 of social", comment: "Alert helping user")
            let message = NSLocalizedString("Please enter the last 4 numbers of your social security number", comment: "Alert helping user")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
        
        let previousButton = navigationItem.rightBarButtonItem
        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
        navigationItem.rightBarButtonItem = spinButton
        
        store.privateContext { [weak self] privateContext in
            let completion: (_ userID: NSManagedObjectID?, _ error: Error?) -> Void = { userID, error in
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem = previousButton
                    if error == nil {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            if self?.isFullSocialSecurityNumberRequired == true {
                self?.createPersonalIDNumberToken(personalID: socialSecurityNumber) { token in
                    self?.mechanicNetwork.update(personalIDNumber: token?.tokenId, in: privateContext, completion: completion)
                }
            } else {
                self?.mechanicNetwork.update(socialSecurityNumberLast4: socialSecurityNumber, in: privateContext, completion: completion)
            }
        }
    }
    
    private func updatePlaceholderText() {
        socialSecurityTextField?.placeholder = placeholderText
    }
    
    private var placeholderText: String {
        if isFullSocialSecurityNumberRequired {
            return NSLocalizedString("Full Social Security Number", comment: "Placeholder text")
        } else {
            return NSLocalizedString("Last 4 of Social Security Number", comment: "Placeholder text")
        }
    }
    
    @IBAction private func didChangeSocialSecurityTextField(_ sender: UITextField) {
        
    }
    
    private func createPersonalIDNumberToken(personalID: String, completion: @escaping (_ token: STPToken?) -> Void) {
        STPAPIClient.shared().createToken(withPersonalIDNumber: personalID) { token, error in
            completion(token)
        }
    }
    
}
