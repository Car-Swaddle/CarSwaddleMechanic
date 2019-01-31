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
    
    private var rows: [Row] = Row.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    

    private func setupTableView() {
        tableView.register(ProfileDataCell.self)
        tableView.tableFooterView = UIView()
    }
    
}


extension PersonalInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .address:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.descriptionText = NSLocalizedString("Address", comment: "Description of row")
            cell.valueText = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address?.line1
            return cell
        case .fullSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Full social", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .last4OfSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Last 4 of social", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .bankAccount:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Bank Account", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .documents:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Documents", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .dateOfBirth:
            let cell: ProfileDataCell = tableView.dequeueCell()
            if let dateOfBirth = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.dateOfBirth {
                cell.descriptionText = NSLocalizedString("Date of Birth", comment: "Description of row")
                cell.valueText = dateOfBirthFormatter.string(from: dateOfBirth)
            } else {
                cell.descriptionText = nil
                cell.valueText = NSLocalizedString("Date of Birth", comment: "Description of row")
            }
            return cell
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

