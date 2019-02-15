//
//  SignUpViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import SafariServices


private let stripeAgreementURLString = "https://stripe.com/us/connect-account/legal"
// TODO: Change this to CarSwaddle's service agreement
private let carSwaddleAgreementURLString = "https://stripe.com/us/connect-account/legal"

final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    public static let stripeAgreementURL: URL! = URL(string: stripeAgreementURLString)!
    public static let carSwaddleAgreementURL: URL! = URL(string: carSwaddleAgreementURLString)!
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    private var auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        
        spinner.isHiddenInStackView = true
        updateSignUpEnabledness()
        
        let tintColor = UIColor.textColor2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: tintColor]
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "placeholder text"), attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "placeholder text"), attributes: placeholderAttributes)
        
        emailTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 2.0)
        passwordTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 2.0)
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateSignUpEnabledness()
    }
    
    private func updateSignUpEnabledness() {
        signUpButton.isEnabled = signUpIsAllowed
    }
    
    private var signUpIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapSignUp() {
        signUpIfPossible()
    }
    
    private func signUpIfPossible() {
        guard signUpIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateSignUpEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        signUpButton.isHiddenInStackView = true
        
        store.privateContext { [weak self] context in
            self?.auth.mechanicSignUp(email: email, password: password, context: context) { error in
                guard error == nil && self?.auth.isLoggedIn == true else {
                    DispatchQueue.main.async {
                        self?.spinner.isHiddenInStackView = true
                        self?.spinner.stopAnimating()
                        
                        self?.signUpButton.isHiddenInStackView = false
                    }
                    return
                }
                DispatchQueue.main.async {
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
    }
    
    @IBAction func didTapLogin() {
        let login = LoginViewController.viewControllerFromStoryboard()
        navigationController?.show(login, sender: self)
    }
    
    
    private var safariConfiguration: SFSafariViewController.Configuration {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        return configuration
    }
    
    @IBAction func didTapCarSwaddleAgreement() {
        let stripeSafariViewController = SFSafariViewController(url: SignUpViewController.carSwaddleAgreementURL, configuration: safariConfiguration)
        present(stripeSafariViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapStripeAgreement() {
        let stripeSafariViewController = SFSafariViewController(url: SignUpViewController.stripeAgreementURL, configuration: safariConfiguration)
        present(stripeSafariViewController, animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signUpIfPossible()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignUpEnabledness()
        return true
    }
    
}


public extension String {
    
    private static let validateEmailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    public var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", String.validateEmailRegex)
        return emailTest.evaluate(with: self)
    }
    
    public var isValidPassword: Bool {
        return self.count > 3
    }
    
}
