//
//  EnterNewPasswordViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 5/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleNetworkRequest
import CarSwaddleUI

private let successTitle = NSLocalizedString("Success! You successfully reset your password", comment: "Success message")
private let successMessage = NSLocalizedString("You'll be able to login with your new password right now", comment: "Success message")


class EnterNewPasswordViewController: UIViewController, StoryboardInstantiating {
    
    class func create(resetToken: String) -> EnterNewPasswordViewController {
        let viewController = EnterNewPasswordViewController.viewControllerFromStoryboard()
        viewController.resetToken = resetToken
        return viewController
    }
    
    private var resetToken: String!

    @IBOutlet private weak var createPasswordButton: LoadingButton!
    @IBOutlet private weak var enterNewPasswordLabeledTextField: LabeledTextField!
    
    private let auth: AuthService = AuthService(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        enterNewPasswordLabeledTextField.textField.becomeFirstResponder()
    }
    
    private func configureTextField() {
        enterNewPasswordLabeledTextField.textField.autocorrectionType = .no
        enterNewPasswordLabeledTextField.textField.autocapitalizationType = .none
        enterNewPasswordLabeledTextField.textField.textContentType = .newPassword
        enterNewPasswordLabeledTextField.textField.spellCheckingType = .no
        enterNewPasswordLabeledTextField.textField.isSecureTextEntry = true
    }

    @IBAction private func didTapEnter() {
        guard let password = enterNewPasswordLabeledTextField.textField.text else { return }
        createPasswordButton.isLoading = true
        auth.setNewPassword(newPassword: password, token: resetToken) { [weak self] json, error in
            DispatchQueue.main.async {
                self?.createPasswordButton.isLoading = false
                self?.showSuccessAlert(message: successMessage, title: successTitle)
            }
        }
    }
    
    
    @IBAction private func didTapDoneButton(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
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
