//
//  PersonalInformationViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/30/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CoreData
import Store
import CarSwaddleData

final class PersonalInformationViewController: UIViewController, StoryboardInstantiating {

    private enum Row: CaseIterable {
        case fullSocialSecurityNumber
        case last4OfSocialSecurityNumber
        case address
        case bankAccount
        case documents
        case dateOfBirth
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(PersonalInformationViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    private let stripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    private var rows: [Row] = Row.allCases
    
    private var verification: Verification? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    @objc private func didRefresh() {
        requestData()
    }

    private func setupTableView() {
        tableView.register(ProfileDataCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.updateCurrentUserVerification(in: privateContext) { verificationObjectID, error in
                DispatchQueue.main.async {
                    if let verificationObjectID = verificationObjectID, let verification = store.mainContext.object(with: verificationObjectID) as? Verification {
                        self?.verification = verification
                    }
                }
            }
        }
    }
    
}


extension PersonalInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileDataCell = tableView.dequeueCell()
        
        let row = rows[indexPath.row]
        cell.errorViewIsHidden = self.shouldShowError(for: row)
        
        switch row {
        case .address:
            cell.descriptionText = NSLocalizedString("Address", comment: "Description of row")
            cell.valueText = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address?.line1
        case .fullSocialSecurityNumber:
            cell.valueText = NSLocalizedString("Full social", comment: "Description of row")
            cell.descriptionText = ""
        case .last4OfSocialSecurityNumber:
            cell.valueText = NSLocalizedString("Last 4 of social", comment: "Description of row")
            cell.descriptionText = ""
        case .bankAccount:
            cell.valueText = NSLocalizedString("Bank Account", comment: "Description of row")
            cell.descriptionText = ""
        case .documents:
            cell.valueText = NSLocalizedString("Documents", comment: "Description of row")
            cell.descriptionText = ""
        case .dateOfBirth:
            if let dateOfBirth = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.dateOfBirth {
                cell.descriptionText = NSLocalizedString("Date of Birth", comment: "Description of row")
                cell.valueText = dateOfBirthFormatter.string(from: dateOfBirth)
            } else {
                cell.descriptionText = nil
                cell.valueText = NSLocalizedString("Date of Birth", comment: "Description of row")
            }
        }
        return cell
    }
    
    
    private func shouldShowError(for row: Row) -> Bool {
        guard let verification = verification else { return false }
        switch row {
        case .address:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                if field == .addressCity || field == .addressState || field == .addressLine1 || field == .addressPostalCode {
                    return true
                } else {
                    return false
                }
            })
        case .fullSocialSecurityNumber:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                return field == .personalIDNumber
            })
        case .last4OfSocialSecurityNumber:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                return field == .socialSecurityNumberLast4Digits
            })
        case .bankAccount:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                return field == .externalAccount
            })
        case .documents:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                return field == .verificationDocument
            })
        case .dateOfBirth:
            return verification.typedFieldsNeeded.contains(where: { (field) -> Bool in
                return field == .birthdayYear || field == .birthdayMonth || field == .birthdayDay
            })
        }
    }
    
}

extension PersonalInformationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .address:
            let viewController = AddressViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        case .fullSocialSecurityNumber:
            let viewController = IdentificationInfoViewController.viewControllerFromStoryboard()
            viewController.isFullSocialSecurityNumberRequired = true
            show(viewController, sender: self)
        case .last4OfSocialSecurityNumber:
            let viewController = IdentificationInfoViewController.viewControllerFromStoryboard()
            viewController.isFullSocialSecurityNumberRequired = false
            show(viewController, sender: self)
        case .bankAccount:
            let viewController = BankAccountViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        case .documents:
            let viewController = FilePickerViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        case .dateOfBirth:
            let date = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.dateOfBirth
            let viewController = DateOfBirthViewController.create(with: date)
            show(viewController, sender: self)
        }
    }
    
}

