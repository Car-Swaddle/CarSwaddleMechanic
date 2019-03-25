//
//  PhoneNumberViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData

final class PhoneNumberViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {
    
    weak var navigationDelegate: NavigationDelegate?

    private var phoneNumberTextField: UITextField {
        return phoneNumberLabeledTextField.textField
    }
    
    @IBOutlet private var phoneNumberLabeledTextField: LabeledTextField!
    @IBOutlet private var actionButton: ActionButton!
    
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    lazy private var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insetAdjuster.showActionButtonAboveKeyboard = true
        insetAdjuster.includeTabBarInKeyboardCalculation = tabBarController != nil
        insetAdjuster.positionActionButton()
        
        phoneNumberTextField.textContentType = .telephoneNumber
        phoneNumberTextField.autocorrectionType = .no
        phoneNumberTextField.autocapitalizationType = .none
        phoneNumberTextField.returnKeyType = .done
        phoneNumberTextField.keyboardType = .numbersAndPunctuation
        
        phoneNumberTextField.delegate = self
    }
    

    @IBAction func didTapSave() {
        let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard phoneNumber?.isEmpty == false else { return }
        
        actionButton.isLoading = true
        store.privateContext { [weak self] context in
            self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: phoneNumber, token: nil, timeZone: nil, in: context) { userObjectID, error in
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


extension PhoneNumberViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSave()
        return true
    }
    
}
