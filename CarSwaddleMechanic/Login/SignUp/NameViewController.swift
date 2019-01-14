//
//  NameViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData

final class NameViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {

    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    
    weak var navigationDelegate: NavigationDelegate?
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    
    private var currentUser: User? = User.currentUser(context: store.mainContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.text = currentUser?.firstName
        lastNameTextField.text = currentUser?.lastName
    }
    
    @IBAction func firstNameTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction func lastNameTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    
    @IBAction private func didTapSave() {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text else { return }
        let previousBarButtonItem = navigationItem.rightBarButtonItem
        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
        navigationItem.rightBarButtonItem = spinButton
        store.privateContext { [weak self] privateContext in
            self?.userNetwork.update(firstName: firstName, lastName: lastName, phoneNumber: nil, token: nil, in: privateContext) { userObjectID, error in
                DispatchQueue.main.async {
                    guard error == nil else { return }
                    if let self = self, let navigationDelegate = self.navigationDelegate {
                        navigationDelegate.didFinish(navigationDelegatingViewController: self)
                    } else {
                        if error == nil {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        self?.navigationItem.rightBarButtonItem = previousBarButtonItem
                    }
                }
            }
        }
    }
    
}
