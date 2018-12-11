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
    
    private let auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func didTapLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        store.privateContext { [weak self] context in
            self?.auth.mechanicLogin(email: email, password: password, context: context) { [weak self] error in
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
