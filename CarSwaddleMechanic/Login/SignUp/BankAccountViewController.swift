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

    @IBOutlet private weak var routingNumberDigitEntryView: OneTimeCodeEntryView!
    @IBOutlet private weak var bankAccountNumberLabeledTextField: LabeledTextField!
    @IBOutlet private weak var accountHolderLabeledTextField: LabeledTextField!
    @IBOutlet private weak var routingNumberLabel: UILabel!
    
    @IBOutlet private weak var actionButton: ActionButton!
    
    private var mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var stripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    private let routingNumberDigits = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        routingNumberDigitEntryView.digits = routingNumberDigits
        routingNumberDigitEntryView.textFieldWidth = 27
        routingNumberDigitEntryView.styleDefault()
        routingNumberDigitEntryView.textFieldFont = UIFont.appFont(type: .regular, size: 17)
        
        routingNumberDigitEntryView.delegate = self
        
        routingNumberLabel.font = UIFont.appFont(type: .semiBold, size: 15)
        routingNumberLabel.text = NSLocalizedString("Routing number", comment: "Label for bank routing number")
        
        bankAccountNumberLabeledTextField.textField.keyboardType = .numberPad
        bankAccountNumberLabeledTextField.textField.autocorrectionType = .no
        bankAccountNumberLabeledTextField.textField.autocapitalizationType = .none
        
        updateUI()
        
        insetAdjuster.showActionButtonAboveKeyboard = true
        insetAdjuster.positionActionButton()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BankAccountViewController.didTapView))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapView() {
        routingNumberDigitEntryView.resignFirstResponder()
        bankAccountNumberLabeledTextField.textField.resignFirstResponder()
        accountHolderLabeledTextField.textField.resignFirstResponder()
    }
    
    private func updateUI() {
        guard let bankAccount = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.bankAccount else { return }
        
        routingNumberDigitEntryView.setText(bankAccount.routingNumber)
        let maskedBankAccount = "••••••••" + bankAccount.last4
        bankAccountNumberLabeledTextField.textField.text = maskedBankAccount
        accountHolderLabeledTextField.textField.text = bankAccount.accountHolderName
        
        bankAccountNumberLabeledTextField.updateLabelFontForCurrentText()
        accountHolderLabeledTextField.updateLabelFontForCurrentText()
        
        updateRoutingNumberLabel()
    }
    
    private func requestData(completion: @escaping () -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.requestBankAccount(in: privateContext) { bankAccountObjectID, error in
                completion()
            }
        }
    }
    
    
    @IBAction private func routingNumberTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction private func bankAccountNumberTextFieldDidChange(_ sender: UITextField) {
        
    }
    
    @IBAction private func didTapSave() {
//        let previousButton = navigationItem.rightBarButtonItem
//        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
//        navigationItem.rightBarButtonItem = spinButton
        
        actionButton.isLoading = true
        generateBankAccountToken { [weak self] token in
            guard let token = token?.tokenId else {
                DispatchQueue.main.async {
//                    self?.navigationItem.rightBarButtonItem = previousButton
                }
                return
            }
            store.privateContext { privateContext in
                self?.mechanicNetwork.update(externalAccount: token, in: privateContext) { mechanicObjectID, error in
                    DispatchQueue.main.async {
                        self?.actionButton.isLoading = false
//                        self?.navigationItem.rightBarButtonItem = previousButton
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
        let routingNumber = routingNumberDigitEntryView.code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let bankAccountNumber = bankAccountNumberLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let accountHolderName = accountHolderLabeledTextField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            routingNumber.count == routingNumberDigits else {
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

extension BankAccountViewController: OneTimeEntryViewDelegate {
    
    func configureTextField(textField: DeletingTextField, view: OneTimeCodeEntryView) {
        
    }
    
    func codeDidChange(code: String, view: OneTimeCodeEntryView) {
        updateRoutingNumberLabel()
    }
    
    private func updateRoutingNumberLabel() {
        if routingNumberDigitEntryView.code.isEmpty {
            routingNumberLabel.font = UIFont.appFont(type: .semiBold, size: 15)
        } else {
            routingNumberLabel.font = UIFont.appFont(type: .regular, size: 15)
        }
    }
    
}
