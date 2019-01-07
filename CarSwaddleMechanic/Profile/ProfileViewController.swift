//
//  ProfileViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData
import Authentication

final class ProfileViewController: UIViewController, StoryboardInstantiating {
    
    private enum Row: CaseIterable {
        case firstName
        case lastName
        case serviceRegion
        case mechanicActive
        case fullSocialSecurityNumber
        case last4OfSocialSecurityNumber
        case address
        case bankAccount
        case documents
        case dateOfBirth
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private var rows: [Row] = Row.allCases
    private var user: User? {
        didSet { tableView.reloadData() }
    }
    private var userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private let auth = Auth(serviceRequest: serviceRequest)
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addRefreshTarget(target: self, action: #selector(ProfileViewController.didRefresh))
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        user = User.currentUser(context: store.mainContext)
        
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func didRefresh() {
        updateData { [weak self] error in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func updateData(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        store.privateContext { [weak self] context in
            self?.userNetwork.requestCurrentUser(in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    if let userObjectID = userObjectID {
                        self?.user = mainContext.object(with: userObjectID) as? User
                    }
                    completion(error)
                }
            }
        }
    }
    
    @IBAction func didSelectOptions(_ sender: Any) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let title = NSLocalizedString("Logout", comment: "title of button to logout")
        let logoutAction = UIAlertAction(title: title, style: .destructive) { [weak self] action in
            self?.auth.logout { error in
                DispatchQueue.main.async {
                    finishTasksAndInvalidate {
                        try? store.destroyAllData()
                        AuthController().removeToken()
                        DispatchQueue.main.async {
                            navigator.navigateToLoggedOutViewController()
                        }
                    }
                }
            }
        }
        
        actionController.addAction(logoutAction)
        actionController.addCancelAction()
        
        present(actionController, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileServiceRegionCell.self)
        tableView.register(NameCell.self)
        tableView.register(MechanicActiveCell.self)
        tableView.register(ProfileDataCell.self)
    }
    
    @IBAction func didSelectEditSchedule() {
        let availability = AvailabilityViewController.create()
        show(availability, sender: true)
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        
        switch row {
        case .firstName, .lastName:
            let viewController = NameViewController.viewControllerFromStoryboard()
            navigationController?.show(viewController, sender: nil)
        case .serviceRegion:
            let serviceRegion = ServiceRegionViewController.viewControllerFromStoryboard()
            show(serviceRegion, sender: self)
        case .mechanicActive: break
        case .address:
            let viewController = PersonalInformationViewController.viewControllerFromStoryboard()
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
            let viewController = DateOfBirthViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        }
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .firstName:
            let cell: NameCell = tableView.dequeueCell()
            cell.textLabel?.text = user?.firstName
            return cell
        case .lastName:
            let cell: NameCell = tableView.dequeueCell()
            cell.textLabel?.text = user?.lastName
            return cell
        case .serviceRegion:
            let cell: ProfileServiceRegionCell = tableView.dequeueCell()
            if let region = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.serviceRegion {
                cell.configure(with: region)
            }
            return cell
        case .mechanicActive:
            let cell: MechanicActiveCell = tableView.dequeueCell()
            return cell
        case .address:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.descriptionLabel.text = NSLocalizedString("Address", comment: "Description of row")
            cell.valueLabel.text = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address?.line1
            return cell
        case .fullSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueLabel.text = NSLocalizedString("Full social", comment: "Description of row")
            cell.descriptionLabel.text = ""
            return cell
        case .last4OfSocialSecurityNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueLabel.text = NSLocalizedString("Last 4 of social", comment: "Description of row")
            cell.descriptionLabel.text = ""
            return cell
        case .bankAccount:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueLabel.text = NSLocalizedString("Bank Account", comment: "Description of row")
            cell.descriptionLabel.text = ""
            return cell
        case .documents:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueLabel.text = NSLocalizedString("Documents", comment: "Description of row")
            cell.descriptionLabel.text = ""
            return cell
        case .dateOfBirth:
            let cell: ProfileDataCell = tableView.dequeueCell()
            if let dateOfBirth = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.dateOfBirth {
                cell.descriptionLabel.text = NSLocalizedString("Date of Birth", comment: "Description of row")
                cell.valueLabel.text = dateOfBirthFormatter.string(from: dateOfBirth)
            } else {
                cell.descriptionLabel.text = nil
                cell.valueLabel.text = NSLocalizedString("Date of Birth", comment: "Description of row")
            }
            return cell
        }
    }
    
//    private func description(for row: Row) -> String? {
//        switch row {
//        case .firstName: return nil
//        case .lastName: return nil
//        case .serviceRegion: return nil
//        case .mechanicActive: return nil
//        case .identification: return NSLocalizedString("Identification", comment: "Description of row")
//        case .bankAccount:
//            return NSLocalizedString("Bank Account", comment: "Description of row")
//        case .documents:
//            return NSLocalizedString("Documents", comment: "Description of row")
//        case .dateOfBirth:
//            return NSLocalizedString("Date of Birth", comment: "Description of row")
//        }
//    }
    
}
