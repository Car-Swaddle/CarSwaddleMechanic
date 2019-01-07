//
//  IdentificationInfoViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Stripe
import Store
import CarSwaddleData

final class BankAccountViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var routingNumberTextField: UITextField!
    @IBOutlet private weak var bankAccountNumberTextField: UITextField!
    @IBOutlet private weak var accountHolderNameTextField: UITextField!
    
    private var mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountHolderNameTextField.text = User.currentUser(context: store.mainContext)?.displayName
    }
    
    
    @IBAction private func routingNumberTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction private func bankAccountNumberTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction private func didTapSave() {
        let previousButton = navigationItem.rightBarButtonItem
        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
        navigationItem.rightBarButtonItem = spinButton
        generateBankAccountToken { [weak self] token in
            guard let token = token?.tokenId else {
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem = previousButton
                }
                return
            }
            store.privateContext { privateContext in
                self?.mechanicNetwork.update(externalAccount: token, in: privateContext) { mechanicObjectID, error in
                    DispatchQueue.main.async {
                        self?.navigationItem.rightBarButtonItem = previousButton
                        if let error = error {
                            print("error: \(error)")
                        } else {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func generateBankAccountToken(completion: @escaping (_ token: STPToken?) -> Void) {
        guard let routingNumber = routingNumberTextField.text,
            let bankAccountNumber = bankAccountNumberTextField.text,
            let accountHolderName = accountHolderNameTextField.text else {
                completion(nil)
                return
        }
        
        let bankAccountParameters = STPBankAccountParams()
        bankAccountParameters.country = "US"
        bankAccountParameters.currency = "usd"
        bankAccountParameters.accountHolderType = .individual
        bankAccountParameters.accountHolderName = accountHolderName
        bankAccountParameters.routingNumber = routingNumber
        bankAccountParameters.accountNumber = bankAccountNumber
        
        STPAPIClient.shared().createToken(withBankAccount: bankAccountParameters) { token, error in
            completion(token)
        }
    }
    
}
