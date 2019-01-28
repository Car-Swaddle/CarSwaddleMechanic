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
    
    private var auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapSignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        store.privateContext { [weak self] context in
            self?.auth.mechanicSignUp(email: email, password: password, context: context) { error in
                guard error == nil && self?.auth.isLoggedIn == true else { return }
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
