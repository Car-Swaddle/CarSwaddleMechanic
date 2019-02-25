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
import Store

final class LoginViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    private var task: URLSessionDataTask?
    
    private var auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        setupNotifications()
        emailTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.didChangeTextField(_:)), for: .editingChanged)
        
        let tintColor = UIColor.textColor2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: UIFont.appFont(type: .semiBold, size: 15)]
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
    
    private func loginIfPossible() {
        guard loginIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateLoginEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        loginButton.isHiddenInStackView = true
        
        store.privateContext { [weak self] context in
            self?.task = self?.auth.mechanicLogin(email: email, password: password, context: context) { [weak self] error in
                guard error == nil && self?.auth.isLoggedIn == true else {
                    DispatchQueue.main.async {
                        self?.spinner.isHiddenInStackView = true
                        self?.spinner.stopAnimating()
                        
                        self?.loginButton.isHiddenInStackView = false
                    }
                    return
                }
                DispatchQueue.main.async {
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
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
