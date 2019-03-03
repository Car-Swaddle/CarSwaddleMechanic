//
//  PersonalInformationViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/24/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import Authentication
import CarSwaddleData


private let localAddressID = "localAddressID"

final class AddressViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var tableView: UITableView!
    
    private var address: Address? = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address ?? Address.fetch(with: localAddressID, in: store.mainContext)
    private var mechanicService: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private let auth = Auth(serviceRequest: serviceRequest)
    
    private enum Row: CaseIterable {
        case addressLine1
        case postalCode
        case city
        case state
    }
    
    private var rows: [Row] = Row.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if address == nil {
            address = Address(context: store.mainContext)
            address?.identifier = localAddressID
            store.mainContext.persist()
        }

        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(PersonalInformationCell.self)
        tableView.register(DateOfBirthCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func didTapSave() {
        guard let address = address else { return }
        
        address.city = address.city?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.postalCode = address.postalCode?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.state = address.state?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.line1 = address.line1?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.managedObjectContext?.persist()
        
        let previousButton = navigationItem.rightBarButtonItem
        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
        navigationItem.rightBarButtonItem = spinButton
        
        let addressID = address.objectID
        store.privateContext { [weak self] privateContext in
            guard let privateAddress = privateContext.object(with: addressID) as? Address else { return }
            self?.mechanicService.update(isActive: nil, token: nil, dateOfBirth: nil, address: privateAddress, in: privateContext) { mechanicObjectID, error in
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem = previousButton
                    if error == nil {
                        self?.navigationController?.popViewController(animated: true)
                        if let fetchedAddress = store.mainContext.object(with: addressID) as? Address {
                            store.mainContext.delete(fetchedAddress)
                        }
                    }
                }
            }
        }
    }
    
//    @IBAction private func didTapLogout() {
//        auth.logout(deviceToken: pushNotificationController.getDeviceToken()) { error in
//            DispatchQueue.main.async {
//                finishTasksAndInvalidate {
//                    try? store.destroyAllData()
//                    AuthController().removeToken()
//                    pushNotificationController.deleteDeviceToken()
//                    DispatchQueue.main.async {
//                        navigator.navigateToLoggedOutViewController()
//                    }
//                }
//            }
//        }
//    }
    
}

extension AddressViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .addressLine1, .city, .postalCode, .state:
            let cell: PersonalInformationCell = tableView.dequeueCell()
            cell.label.text = self.title(for: row)
            cell.textField.text = valueText(for: row)
            configure(for: cell.textField, row: row)
            
            cell.didChangeText = { [weak self] text in
                switch row {
                case .addressLine1: self?.address?.line1 = text
                case .city: self?.address?.city = text
                case .postalCode: self?.address?.postalCode = text
                case .state: self?.address?.state = text
                }
                store.mainContext.persist()
            }
            return cell
        }
    }
    
    private func title(for row: Row) -> String {
        switch row {
        case .city: return NSLocalizedString("City:", comment: "title of given row")
        case .addressLine1: return NSLocalizedString("Line 1:", comment: "title of given row")
        case .postalCode: return NSLocalizedString("Postal Code:", comment: "title of given row")
        case .state: return NSLocalizedString("State:", comment: "title of given row")
        }
    }
    
    private func valueText(for row: Row) -> String? {
        switch row {
        case .city: return address?.city
        case .addressLine1: return address?.line1
        case .postalCode: return address?.postalCode
        case .state: return address?.state
        }
    }
    
    private func configure(for textField: UITextField, row: Row) {
        switch row {
        case .addressLine1:
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.textContentType = .streetAddressLine1
        case .city:
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.textContentType = .addressCity
        case .postalCode:
            textField.autocapitalizationType = .none
            textField.keyboardType = .asciiCapableNumberPad
            textField.autocorrectionType = .no
            textField.textContentType = .postalCode
        case .state:
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .yes
            textField.textContentType = .addressState
        }
        textField.smartInsertDeleteType = .yes
    }
    
}

extension AddressViewController: UITableViewDelegate {
    
    
    
}
