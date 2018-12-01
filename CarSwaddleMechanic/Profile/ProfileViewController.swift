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
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private var rows: [Row] = Row.allCases
    private var user: User? {
        didSet {
            tableView.reloadData()
        }
    }
    private var userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private let auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        user = User.currentUser(context: store.mainContext)
        
        store.privateContext { [weak self] context in
            self?.userNetwork.requestCurrentUser(in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    if let userObjectID = userObjectID {
                        self?.user = mainContext.object(with: userObjectID) as? User
                    }
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
                    finishTasksAndInvalidate()
                    try? store.destroyAllData()
                    AuthController().removeToken()
                    navigator.navigateToLoggedOutViewController()
                }
            }
        }
        
        actionController.addAction(logoutAction)
        actionController.addCancelAction()
        
        present(actionController, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileServiceRegionCell.self)
        tableView.register(NameCell.self)
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
        case .firstName: break
        case .lastName: break
        case .serviceRegion:
            let serviceRegion = ServiceRegionViewController.viewControllerFromStoryboard()
            show(serviceRegion, sender: self)
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
        }
    }
    
}
