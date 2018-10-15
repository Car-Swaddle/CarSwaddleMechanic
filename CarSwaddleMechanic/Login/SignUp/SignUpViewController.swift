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

final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let auth = Auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction private func didTapSignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        store.privateContext { [weak self] context in
            self?.auth.signUp(email: email, password: password, context: context) { error in
//                print("logged in: \(String(describing: error))")
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
}
