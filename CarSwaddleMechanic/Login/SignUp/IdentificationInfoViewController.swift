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
            updateNumberOfDigits()
            updateExplanationText()
        }
    }
    
    private func updateExplanationText() {
        explanationLabel.text = explanationText
    }
    
    private func updateNumberOfDigits() {
        entryView.digits = numberOfDigits
    }
    
    private var numberOfDigits: Int {
        if isFullSocialSecurityNumberRequired {
            return 9
        } else {
            return 4
        }
    }
    
    @IBOutlet private weak var entryView: OneTimeCodeEntryView!
    @IBOutlet private weak var bottomLabel: UILabel!
    
    @IBOutlet weak var explanationLabel: UILabel!
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var actionButton: ActionButton!
    lazy private var contentAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlaceholderText()
        
        contentAdjuster.positionActionButton()
        contentAdjuster.showActionButtonAboveKeyboard = true
        
        updateNumberOfDigits()
        entryView.textFieldCornerRadius = 6
        entryView.textFieldWidth = 29
        entryView.textFieldBackgroundColor = UIColor(white255: 244)
        entryView.spacing = 4
        entryView.textFieldFont = UIFont.appFont(type: .semiBold, size: 17)
        entryView.spacerFont = UIFont.appFont(type: .regular, size: 20)
        entryView.isSecureTextEntry = false
        entryView.textFieldTintColor = .viewBackgroundColor1
        entryView.underlineColor = .viewBackgroundColor1
        _ = entryView.becomeFirstResponder()
        
        updateExplanationText()
        updateSpacerIndexes()
        
        view.layoutIfNeeded()
    }
    
    private func updateSpacerIndexes() {
        entryView.indexesPrecedingSpacer = spacerIndexes
    }
    
    private var spacerIndexes: [Int] {
        if isFullSocialSecurityNumberRequired {
            return [2,4]
        } else {
            return []
        }
    }
    
    private var explanationText: String {
        if isFullSocialSecurityNumberRequired {
            return NSLocalizedString("Your social security number is required in order to send you your tax documents at the end of the year. This may be a requirement in order for funds to be put into your account", comment: "Social security number explnation")
        } else {
            return NSLocalizedString("The last four digits of your social security number are required in order to send you your tax documents at the end of the year. This may be a requirement in order for funds to be put into your account.", comment: "Social security number explnation")
        }
    }
    
    @IBAction private func didTapSave() {
        let socialSecurityNumber = entryView.code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard socialSecurityNumber.count == numberOfDigits else { return }
        
        if isFullSocialSecurityNumberRequired == false && socialSecurityNumber.count != 4 {
            let title = NSLocalizedString("Should enter last 4 of social", comment: "Alert helping user")
            let message = NSLocalizedString("Please enter the last 4 numbers of your social security number", comment: "Alert helping user")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
        
        actionButton.isLoading = true
        
        store.privateContext { [weak self] privateContext in
            let completion: (_ userID: NSManagedObjectID?, _ error: Error?) -> Void = { userID, error in
                DispatchQueue.main.async {
                    self?.actionButton.isLoading = false
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
        bottomLabel.text = placeholderText
    }
    
    private var placeholderText: String {
//        return ""
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




open class UnderlineTextField: UITextField {
    
    @IBInspectable public var underlineColor: UIColor = .black {
        didSet {
            underlineView?.backgroundColor = underlineColor
        }
    }
    
    private var underlineView: UIView!
    
    private func setup() {
        self.underlineView = addHairlineView(toSide: .bottom, color: underlineColor, size: 2.0, insets: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        underlineView.isHidden = true
        borderStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(UnderlineTextField.didBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(UnderlineTextField.didEndEditing), name: UITextField.textDidEndEditingNotification, object: self)
    }
    
    @objc private func didBeginEditing() {
        underlineView.isHidden = false
        underlineView.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.underlineView.alpha = 1.0
        }
    }
    
    @objc private func didEndEditing() {
        UIView.animate(withDuration: 0.25, animations: {
            self.underlineView.alpha = 0.0
        }) { isFinished in
            self.underlineView.alpha = 1.0
            self.underlineView.isHidden = true
        }
    }
    
}


extension OneTimeCodeEntryView {
    
    func styleDefault() {
        textFieldCornerRadius = 6
        textFieldWidth = 29
        textFieldBackgroundColor = UIColor(white255: 244)
        spacing = 4
        textFieldFont = UIFont.appFont(type: .semiBold, size: 17)
        spacerFont = UIFont.appFont(type: .regular, size: 20)
        textFieldTintColor = .viewBackgroundColor1
        underlineColor = .viewBackgroundColor1
    }
    
}
