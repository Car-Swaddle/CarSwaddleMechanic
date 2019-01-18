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
    private var mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    private let auth = Auth(serviceRequest: serviceRequest)
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addRefreshTarget(target: self, action: #selector(ProfileViewController.didRefresh))
        return refresh
    }()
    
    private lazy var headerView: ProfileHeaderView = {
        let view = ProfileHeaderView.viewFromNib()
        view.delegate = self
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 130)
        return view
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
            self?.auth.logout(deviceToken: pushNotificationController.getDeviceToken()) { error in
                DispatchQueue.main.async {
                    finishTasksAndInvalidate {
                        try? store.destroyAllData()
                        try? profileImageStore.destroy()
                        AuthController().removeToken()
                        pushNotificationController.deleteDeviceToken()
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
        
        tableView.tableHeaderView = headerView
        if let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext) {
            headerView.configure(with: mechanic)
        }
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


extension ProfileViewController: ProfileHeaderViewDelegate {
    
    func didSelectCamera(headerView: ProfileHeaderView) {
        let imagePicker = self.imagePicker(source: .camera)
        present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectCameraRoll(headerView: ProfileHeaderView) {
        let imagePicker = self.imagePicker(source: .photoLibrary)
        present(imagePicker, animated: true, completion: nil)
    }
    
    func presentAlert(alert: UIAlertController, headerView: ProfileHeaderView) {
        present(alert, animated: true, completion: nil)
    }
    
    private func imagePicker(source: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = false
        return imagePicker
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        guard let image = info[.originalImage] as? UIImage else { return }
        let orientedImage = UIImage.imageWithCorrectedOrientation(image)
        guard let imageData = orientedImage.resized(toWidth: 300 * UIScreen.main.scale)?.pngData() else {
            return
        }
        guard let url = try? profileImageStore.storeFile(data: imageData, fileName: Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier ?? "profileImage") else {
            return
        }
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.setProfileImage(fileURL: url, in: privateContext) { mechanicObjectID, error in
                store.mainContext { mainContext in
                    guard let mechanicObjectID = mechanicObjectID else { return }
                    guard let mechanic = mainContext.object(with: mechanicObjectID) as? Mechanic else { return }
                    self?.headerView.configure(with: mechanic)
                }
            }
        }
    }
    
}
