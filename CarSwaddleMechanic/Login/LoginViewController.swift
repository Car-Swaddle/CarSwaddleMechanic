//
//  LoginViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleStore

private let unableToLoginErrorTitle = NSLocalizedString("Car Swaddle wasn't able to log you in", comment: "Error message")
private let unableToLoginErrorMessage = NSLocalizedString("Your email or password was incorrect. Please verify your email and password and try again.", comment: "Error message")

final class LoginViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    private var task: URLSessionDataTask?
    
    private var auth = Auth(serviceRequest: serviceRequest)
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        setupNotifications()
        emailTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        
        let tintColor = UIColor.textColor2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: UIFont.appFont(type: .semiBold, size: 15) as Any]
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "placeholder text"), attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "placeholder text"), attributes: placeholderAttributes)
        
        emailTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        passwordTextField.addHairlineView(toSide: .bottom, color: UIColor.textColor1, size: 1.0)
        
        spinner.isHiddenInStackView = true
        updateLoginEnabledness()
        
        backgroundImageView.image = backgroundImage
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateLoginEnabledness()
    }
    
    private func updateLoginEnabledness() {
        loginButton.isEnabled = loginIsAllowed
    }
    
    private var loginIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func willResignActive() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func didBecomeActive() {
        if emailTextField.text == nil || emailTextField.text?.isEmpty == true {
            emailTextField.becomeFirstResponder()
        } else if passwordTextField.text == nil || passwordTextField.text?.isEmpty == true {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapLogin() {
        loginIfPossible()
    }
    
    @IBAction private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapForgotPassword() {
        let forgotPassword = ForgotPasswordViewController.viewControllerFromStoryboard()
        forgotPassword.previousEmailAddress = emailTextField.text
        present(forgotPassword.inNavigationController(), animated: true, completion: nil)
    }
    
    
    
    private func loginIfPossible() {
        guard loginIsAllowed,
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text else {
                updateLoginEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        loginButton.isHiddenInStackView = true
        
        login(email: email, password: password) { [weak self] error in
            guard error == nil && self?.auth.isLoggedIn == true else {
                DispatchQueue.main.async {
                    self?.spinner.isHiddenInStackView = true
                    self?.spinner.stopAnimating()
                    self?.loginButton.isHiddenInStackView = false
                    
                    self?.showError(message: unableToLoginErrorMessage, title: unableToLoginErrorTitle)
                }
                return
            }
            DispatchQueue.main.async {
                navigator.navigateToLoggedInViewController()
            }
        }
    }
    
    private func login(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        store.privateContext { [weak self] context in
            self?.task = self?.auth.mechanicLogin(email: email, password: password, context: context) { [weak self] error in
                self?.userNetwork.update(firstName: nil, lastName: nil, phoneNumber: nil, token: nil, timeZone: TimeZone.current.identifier, in: context) { userObjectID, userError in
                    completion(error)
                }
            }
        }
    }
    
    private func showError(message: String, title: String) {
        let contentView = CustomAlertContentView.view(withTitle: title, message: message)
        contentView.addOkayAction()
        let alert = CustomAlertController.viewController(contentView: contentView)
        present(alert, animated: true, completion: nil)
    }
    
    
    private var backgroundImage: UIImage? {
        let top = GradientPoint(location: 1.0, color: UIColor.viewBackgroundColor1.color(adjustedBy255Points: 15))
        let middle = GradientPoint(location: 0.6, color: UIColor.viewBackgroundColor1.color(adjustedBy255Points: 0))
        let bottom = GradientPoint(location: 0.0, color: UIColor.viewBackgroundColor1.color(adjustedBy255Points: -15))
        return UIImage(size: view.bounds.size, gradientPoints: [top, middle, bottom])
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginIfPossible()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateLoginEnabledness()
        return true
    }
    
}
