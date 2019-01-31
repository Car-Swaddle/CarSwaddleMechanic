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
    
    private var task: URLSessionDataTask?
    
    private var auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        setupNotifications()
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
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        store.privateContext { [weak self] context in
            self?.task = self?.auth.mechanicLogin(email: email, password: password, context: context) { [weak self] error in
                guard error == nil && self?.auth.isLoggedIn == true else {
                    return
                }
                DispatchQueue.main.async {
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
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
        print("called should change")
        return true
    }
    
}
