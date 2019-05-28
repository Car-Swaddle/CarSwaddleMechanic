//
//  ForgotPasswordViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 5/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest

private let unableToLoginErrorTitle = NSLocalizedString("Car Swaddle wasn't able to send a reset link to %@", comment: "Error message")
private let unableToLoginErrorMessage = NSLocalizedString("Something went wrong. We were unable to send a password reset link to %@.\n\nYou may not have an account with that email address. Please verify %@ is correct. If it is correct, go ahead and create an account!", comment: "Error message")
private let unableToLoginErrorMessageNoEmail = NSLocalizedString("It doesn't look like you have an account with %@. Please verify %@ is correct. If it is, go ahead and sign up with Car Swaddle!", comment: "Error message")

private let successfullySentResetLinkTitle = NSLocalizedString("Success! Car Swaddle sent a password reset link to %@", comment: "Success message")
private let successfullySentResetLinkMessage = NSLocalizedString("Tap on the link you've received to reset your password. It may take a moment for the email to arrive.", comment: "Success message")

class ForgotPasswordViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var sendLinkLabel: UILabel!
    
    @IBOutlet private weak var emailLabeledTextField: LabeledTextField!
    @IBOutlet private weak var sendLinkButton: LoadingButton!
    
    var previousEmailAddress: String? {
        didSet {
            emailLabeledTextField?.textField.text = previousEmailAddress
        }
    }
    
    private var auth = AuthService(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabeledTextField.textField.autocorrectionType = .no
        emailLabeledTextField.textField.autocapitalizationType = .none
        emailLabeledTextField.textField.textContentType = .emailAddress
        emailLabeledTextField.textField.spellCheckingType = .no
        emailLabeledTextField.textField.isSecureTextEntry = false
        emailLabeledTextField.textField.keyboardType = .emailAddress
        
        emailLabeledTextField.textField.becomeFirstResponder()
        
        emailLabeledTextField.textField.text = previousEmailAddress
    }
    
    @IBAction private func didTapSendLink() {
        guard let email = emailLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            email.isValidEmail else {
                return
        }
        sendLinkButton.isLoading = true
        auth.requestUpdatePassword(email: email, app: .carSwaddleMechanic) { [weak self] json, error in
            DispatchQueue.main.async {
                if let error = error {
                    let message: String
                    if error._code == 404 {
                        message = String(format: unableToLoginErrorMessageNoEmail, email, email)
                    } else {
                        message = String(format: unableToLoginErrorMessage, email, email)
                    }
                    let title = String(format: unableToLoginErrorTitle, email)
                    self?.showError(message: message, title: title)
                } else {
                    let title = String(format: successfullySentResetLinkTitle, email)
                    self?.showSuccessAlert(message: successfullySentResetLinkMessage, title: title)
                }
                self?.sendLinkButton.isLoading = false
            }
        }
    }
    
    
    @IBAction private func didTapDoneButton(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showError(message: String, title: String) {
        let contentView = CustomAlertContentView.view(withTitle: title, message: message)
        contentView.addOkayAction()
        let alert = CustomAlertController.viewController(contentView: contentView)
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlert(message: String, title: String) {
        let contentView = CustomAlertContentView.view(withTitle: title, message: message)
        contentView.addOkayAction { action in
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        let alert = CustomAlertController.viewController(contentView: contentView)
        present(alert, animated: true, completion: nil)
    }

}
