//
//  NameViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData

final class NameViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {

    private var firstNameTextField: UITextField {
        return firstNameLabeledTextField.textField
    }
    private var lastNameTextField: UITextField {
        return lastNameLabeledTextField.textField
    }
    
    @IBOutlet private weak var firstNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var lastNameLabeledTextField: LabeledTextField!
    @IBOutlet private weak var actionButton: ActionButton!
    
    weak var navigationDelegate: NavigationDelegate?
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var currentUser: User? = User.currentUser(context: store.mainContext)
    lazy private var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.text = currentUser?.firstName
        lastNameTextField.text = currentUser?.lastName
        
        firstNameTextField.textContentType = .givenName
        firstNameTextField.returnKeyType = .next
        firstNameTextField.delegate = self
        
        lastNameTextField.textContentType = .familyName
        lastNameTextField.returnKeyType = .done
        lastNameTextField.delegate = self
        
        configureTextField(firstNameTextField)
        configureTextField(lastNameTextField)
        
        insetAdjuster.showActionButtonAboveKeyboard = true
        insetAdjuster.positionActionButton()
        insetAdjuster.includeTabBarInKeyboardCalculation = tabBarController != nil
        insetAdjuster.showActionButtonAboveKeyboard = true
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
    }
    
    
    
    @IBAction private func didTapSave() {
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName.isEmpty == false, lastName.isEmpty == false else { return }
        
        actionButton.isLoading = true
        store.privateContext { [weak self] privateContext in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: nil, token: nil, timeZone: nil, in: privateContext) { userObjectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.actionButton.isLoading = false
                    guard error == nil else {
                        print(error ?? "")
                        return
                    }
                    if let navigationDelegate = self.navigationDelegate {
                        navigationDelegate.didFinish(navigationDelegatingViewController: self)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
}


extension NameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            didTapSave()
        }
        return true
    }
    
}
