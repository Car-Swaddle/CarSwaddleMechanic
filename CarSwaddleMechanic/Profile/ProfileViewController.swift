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
//        case firstName
//        case lastName
        case mechanicActive
        case serviceRegion
//        case fullSocialSecurityNumber
//        case last4OfSocialSecurityNumber
//        case address
//        case bankAccount
//        case documents
//        case dateOfBirth
        case schedule
        case personalInformation
        case reviews
        case logout
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private var rows: [Row] = Row.allCases
    private var user: User? {
        didSet { tableView.reloadData() }
    }
    
    private let userNetwork = UserNetwork(serviceRequest: serviceRequest)
    private let mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private let stripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    private let auth = Auth(serviceRequest: serviceRequest)
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addRefreshTarget(target: self, action: #selector(ProfileViewController.didRefresh))
        return refresh
    }()
    
    private lazy var headerView: ProfileHeaderView = {
        let view = ProfileHeaderView.viewFromNib()
        view.delegate = self
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
//        view.translatesAutoresizingMaskIntoConstraints = false
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
            var completionError: Error?
            
            let group = DispatchGroup()
            group.enter()
            self?.userNetwork.requestCurrentUser(in: context) { userObjectID, error in
                store.mainContext { mainContext in
                    if let userObjectID = userObjectID {
                        self?.user = mainContext.object(with: userObjectID) as? User
                    }
                    completionError = error
                    group.leave()
                }
            }
            
            group.enter()
            self?.mechanicNetwork.getCurrentMechanic(in: context) { mechanicObjectID, error in
                completionError = error
                group.leave()
            }
            
            group.enter()
            self?.stripeNetwork.updateCurrentUserVerification(in: context) { verificationObjectID, error in
                completionError = error
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                if let mechanic = self?.user?.mechanic {
                    self?.headerView.configure(with: mechanic)
                }
                self?.tableView.reloadData()
                completion(completionError)
            }
        }
    }
    
//    @IBAction func didSelectOptions(_ sender: Any) {
//        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let title = NSLocalizedString("Logout", comment: "title of button to logout")
//        let logoutAction = UIAlertAction(title: title, style: .destructive) { action in
//            logout.logout()
//        }
//
//        actionController.addAction(logoutAction)
//        actionController.addCancelAction()
//
//        present(actionController, animated: true, completion: nil)
//    }
    
    private func didSelectLogout() {
        let actionTitle = NSLocalizedString("Are you sure you want to logout?", comment: "String shown after user selects logout and before they actually logout")
        let actionController = UIAlertController(title: actionTitle, message: nil, preferredStyle: .actionSheet)
        
        let title = NSLocalizedString("Logout", comment: "title of button to logout")
        let logoutAction = UIAlertAction(title: title, style: .destructive) { action in
            logout.logout()
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
        tableView.register(LogoutCell.self)
        tableView.register(PersonalInformationStatusCell.self)
        
        tableView.tableHeaderView = headerView
//        headerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        if let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext) {
            headerView.configure(with: mechanic)
        }
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        
        switch row {
//        case .firstName, .lastName:
//            let viewController = NameViewController.viewControllerFromStoryboard()
//            show(viewController, sender: nil)
        case .serviceRegion:
            let serviceRegion = ServiceRegionViewController.viewControllerFromStoryboard()
            show(serviceRegion, sender: self)
        case .mechanicActive: break
        case .personalInformation:
            let viewController = PersonalInformationViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        case .schedule:
            let availability = AvailabilityViewController.create()
            show(availability, sender: true)
//        case .address:
//            let viewController = PersonalInformationViewController.viewControllerFromStoryboard()
//            show(viewController, sender: self)
//        case .fullSocialSecurityNumber:
//            let viewController = IdentificationInfoViewController.viewControllerFromStoryboard()
//            viewController.isFullSocialSecurityNumberRequired = true
//            show(viewController, sender: self)
//        case .last4OfSocialSecurityNumber:
//            let viewController = IdentificationInfoViewController.viewControllerFromStoryboard()
//            viewController.isFullSocialSecurityNumberRequired = false
//            show(viewController, sender: self)
//        case .bankAccount:
//            let viewController = BankAccountViewController.viewControllerFromStoryboard()
//            show(viewController, sender: self)
//        case .documents:
//            let viewController = FilePickerViewController.viewControllerFromStoryboard()
//            show(viewController, sender: self)
//        case .dateOfBirth:
//            let date = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.dateOfBirth
//            let viewController = DateOfBirthViewController.create(with: date)
//            show(viewController, sender: self)
        case .reviews:
            let viewController = ReviewsViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
            
        case .logout:
            didSelectLogout()
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
        case .serviceRegion:
            let cell: ProfileServiceRegionCell = tableView.dequeueCell()
            if let region = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.serviceRegion {
                cell.configure(with: region)
            }
            return cell
        case .mechanicActive:
            let cell: MechanicActiveCell = tableView.dequeueCell()
            return cell
        case .schedule:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Schedule", comment: "Description of row")
            cell.descriptionText = nil
            return cell
        case .reviews:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = NSLocalizedString("Reviews", comment: "Description of row")
            cell.descriptionText = nil
            return cell
        case .personalInformation:
            let cell: PersonalInformationStatusCell = tableView.dequeueCell()
            return cell
        case .logout:
            let cell: LogoutCell = tableView.dequeueCell()
//            cell.valueText = NSLocalizedString("Personal Information", comment: "Description of row")
//            cell.descriptionText = nil
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
    
    func didSelectEditName(headerView: ProfileHeaderView) {
        let viewController = NameViewController.viewControllerFromStoryboard()
        show(viewController, sender: self)
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
        guard let imageData = orientedImage.resized(toWidth: 300 * UIScreen.main.scale)?.jpegData(compressionQuality: 1.0) else {
            return
        }
        guard let url = try? profileImageStore.storeFile(data: imageData, fileName: Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier ?? "profileImage") else {
            return
        }
        if let mechanic = user?.mechanic {
            headerView.configure(with: mechanic)
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
