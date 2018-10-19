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
//import Authentication
import Store

final class LoginViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private let auth = Auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func didTapLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        store.privateContext { [weak self] context in
            self?.auth.mechanicLogin(email: email, password: password, context: context) { error in
                DispatchQueue.main.async {
//                    if let currentUserID = User.currentUserID {
//                        let mechanic = Mechanic(context: store.mainContext)
//                        mechanic.identifier = currentUserID
//                        store.mainContext.persist()
//                    }
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
    }
    
}
