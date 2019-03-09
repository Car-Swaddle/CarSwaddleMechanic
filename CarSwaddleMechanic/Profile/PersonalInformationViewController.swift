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
    
    private lazy var currentUser: User? = {
        return User.currentUser(context: store.mainContext)
    }()
    
    private let stripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var rows: [Row] = Row.allCases
    private var hasSentVerificationEmail: Bool = false
    
    private var verification: Verification? = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.verification {
        didSet {
            tableView.reloadData()
            if let verification = verification {
                print("verification: \(verification)")
            }
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
        requestData { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }

    private func setupTableView() {
        tableView.register(ProfileDataCell.self)
        tableView.register(EmailVerificationCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            let group = DispatchGroup()
            group.enter()
            self?.stripeNetwork.updateCurrentUserVerification(in: privateContext) { verificationObjectID, error in
                DispatchQueue.main.async {
                    if let verificationObjectID = verificationObjectID, let verification = store.mainContext.object(with: verificationObjectID) as? Verification {
                        self?.verification = verification
                    }
                    group.leave()
                }
            }
            
            group.enter()
            self?.userNetwork.requestCurrentUser(in: privateContext) { userObjectID, error in
                group.leave()
            }
            
            group.enter()
            self?.stripeNetwork.requestBankAccount(in: privateContext) { bankAccountObjectID, error in
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
    }
    
}


extension PersonalInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        switch row {
        case .address:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
            cell.descriptionText = NSLocalizedString("Address", comment: "Description of row")
            cell.valueText = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address?.line1
            return cell
        case .fullSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
            cell.valueText = NSLocalizedString("Full social security number", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .last4OfSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
            cell.valueText = NSLocalizedString("Last 4 of social security number", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .bankAccount:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
            cell.valueText = NSLocalizedString("Bank Account", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .documents:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
            cell.valueText = NSLocalizedString("Documents", comment: "Description of row")
            cell.descriptionText = ""
            return cell
        case .dateOfBirth:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.errorViewIsHidden = !shouldShowError(for: row)
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
    
    private var emailVerificationFormatString: String {
        if currentUser?.isEmailVerified == true {
            let emailFormatString = NSLocalizedString("%@ Not verified", comment: "Description of row")
            return String(format: emailFormatString, currentUser?.email ?? "")
        } else {
            let emailFormatString = NSLocalizedString("%@ verified", comment: "Description of row")
            return String(format: emailFormatString, currentUser?.email ?? "")
        }
    }
    
    
    private func shouldShowError(for row: Row) -> Bool {
        guard let verification = verification else { return false }
        switch row {
        case .address:
            return verification.addressRequired
        case .fullSocialSecurityNumber:
            return verification.socialSecurityNumberRequired
        case .last4OfSocialSecurityNumber:
            return verification.last4OfSocialSecurityNumberRequired
        case .bankAccount:
            return verification.bankAccountRequired
        case .documents:
            return verification.verificationDocumentRequired
        case .dateOfBirth:
            return verification.dateOfBirthRequired
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
