//
//  AutoServiceDetailsViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/11/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData
import MapKit

let timeAndMonthDayYearShortened: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a M/d/y"
    return formatter
}()

final class AutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(autoServiceID: String) -> AutoServiceDetailsViewController {
        let viewController = AutoServiceDetailsViewController.viewControllerFromStoryboard()
        if let autoService = AutoService.fetch(with: autoServiceID, in: store.mainContext) {
            viewController.autoService = autoService
            viewController.autoServiceID = autoServiceID
        } else {
            viewController.autoServiceID = autoServiceID
        }
        return viewController
    }
    
    public static func create(autoService: AutoService) -> AutoServiceDetailsViewController {
        let viewController = AutoServiceDetailsViewController.viewControllerFromStoryboard()
        viewController.autoService = autoService
        viewController.autoServiceID = autoService.identifier
        return viewController
    }
    
    enum Row {
        case user
        case vehicle
        case location
        case date
        case mechanic
        case serviceType
        case oilType
        case autoServiceStatus
        case cancel
        case notes
    }
    
    private var rows: [Row] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var autoServiceID: String?
    private var autoService: AutoService? {
        didSet {
            DispatchQueue.main.async {
                self.updateRows()
                if let autoService = self.autoService {
                    self.header.configure(with: autoService)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var header: AutoServiceDetailsHeaderView = {
        let view = AutoServiceDetailsHeaderView.viewFromNib()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 120)
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        view.delegate = self
        return view
    }()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(AutoServiceDetailsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData()
    }
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Service Details", comment: "Title of details")
        
        if let autoService = autoService {
            header.configure(with: autoService)
        }
        
        requestData()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        UIView.animate(withDuration: 0.3) {
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        UIView.animate(withDuration: 0.3) {
//            self.navigationController?.navigationBar.shadowImage = UIImage.from(color: .gray2)
//        }
//    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let newYOffset = tableView.contentOffset.y
        let newContentOffset = CGPoint(x: 0, y: -newYOffset)
        UIView.animate(withDuration: 0.25) {
            self.tableView.contentInset.bottom = 0
            self.tableView.scrollIndicatorInsets.bottom = 0
            self.tableView.contentOffset = newContentOffset
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height - navigator.tabBarController.tabBar.bounds.height
        let newYOffset = tableView.contentOffset.y - keyboardHeight
        let newContentOffset = CGPoint(x: 0, y: -newYOffset)
        
        UIView.animate(withDuration: duration) {
            self.tableView.contentInset.bottom = keyboardHeight
            self.tableView.scrollIndicatorInsets.bottom = keyboardHeight
            self.tableView.contentOffset = newContentOffset
        }
    }
    
    private func updateRows() {
        guard let autoService = autoService else { return }
        if autoService.status != .canceled {
            rows = [.vehicle, .location, .date, .notes, .cancel]
        } else {
            rows = [.vehicle, .location, .date, .notes]
        }
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        guard let autoServiceID = autoServiceID else {
            completion()
            return
        }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServiceDetails(autoServiceID: autoServiceID, in: privateContext) { autoServiceObjectID, error in
                store.mainContext { mainContext in
                    defer {
                        completion()
                    }
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                    if let autoServiceObjectID = autoServiceObjectID, error == nil {
                        self?.autoService = mainContext.object(with: autoServiceObjectID) as? AutoService
                    }
                }
            }
        }
    }
    
    private func cancelAutoService() {
        guard let autoServiceID = autoService?.identifier else { return }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.updateAutoService(autoServiceID: autoServiceID, status: .canceled, in: privateContext) { autoServiceObjectID, error in
                guard let autoServiceObjectID = autoServiceObjectID, error == nil else { return }
                store.mainContext { mainContext in
                    self?.autoService = mainContext.object(with: autoServiceObjectID) as? AutoService
                }
            }
        }
    }
    
    private func cancelAlert() -> UIAlertController {
        let title = NSLocalizedString("Are you sure you want to cancel this Autoservice?", comment: "Alert")
        let message = NSLocalizedString("If you cancel this Autoservice, the funds already placed in your account will be removed and the customer will receive their funds back.", comment: "Alert")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let actionTitle = NSLocalizedString("Cancel Autoservice", comment: "Action title")
        let cancelAutoServiceAction = UIAlertAction(title: actionTitle, style: .destructive) { [weak self] action in
            self?.cancelAutoService()
        }
        
        alert.addAction(cancelAutoServiceAction)
        
        let backTitle = NSLocalizedString("Dismiss", comment: "Action title cancel")
        let backAction = UIAlertAction(title: backTitle, style: .cancel)
        
        alert.addAction(backAction)
        
        return alert
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceItemCell.self)
        tableView.register(AutoServiceLocationCell.self)
        tableView.register(AutoServiceStatusCell.self)
        tableView.register(AutoServiceVehicleCell.self)
        tableView.register(CancelAutoServiceCell.self)
        tableView.register(NotesTableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = header
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
    }
    
    private func text(for row: Row) -> String? {
        switch row {
        case .date:
            if let scheduledDate = autoService?.scheduledDate {
                return timeAndMonthDayYearShortened.string(from: scheduledDate)
            }
            return nil
        case .user: return autoService?.creator?.displayName
        case .mechanic: return autoService?.mechanic?.user?.displayName
        case .location: return autoService?.location?.streetAddress
        case .vehicle: return autoService?.vehicle?.name
        case .serviceType: return autoService?.serviceEntities.first?.entityType.localizedString
        case .oilType: return autoService?.serviceEntities.first?.oilChange?.oilType.localizedString
        case .autoServiceStatus: return autoService?.status.localizedString
        case .notes: return nil
        case .cancel: return nil
        }
    }
    
    private func detailsText(for row: Row) -> String? {
        switch row {
        case .date: return nil
        case .user: return nil
        case .mechanic: return nil
        case .location: return nil
        case .vehicle: return autoService?.vehicle?.licensePlate
        case .serviceType: return nil
        case .oilType: return nil
        case .autoServiceStatus: return nil
        case .notes: return nil
        case .cancel: return nil
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .location:
            let cell: AutoServiceLocationCell = tableView.dequeueCell()
            if let location = autoService?.location {
                cell.configure(with: location)
            }
            return cell
        case .autoServiceStatus:
            let cell: AutoServiceStatusCell = tableView.dequeueCell()
            if let autoService = autoService {
                cell.configure(with: autoService)
            }
            return cell
        case .vehicle:
            let cell: AutoServiceVehicleCell = tableView.dequeueCell()
            if let autoService = autoService {
                cell.configure(with: autoService)
            }
            return cell
        case .cancel:
            let cell: CancelAutoServiceCell = tableView.dequeueCell()
            return cell
        case .notes:
            let cell: NotesTableViewCell = tableView.dequeueCell()
            if let autoService = autoService {
                cell.configure(with: autoService)
            }
            return cell
        case .date, .mechanic, .serviceType, .user, .oilType:
            let cell: AutoServiceItemCell = tableView.dequeueCell()
            let autoService = rows[indexPath.row]
            cell.titleText = self.text(for: autoService)
            cell.subtitleText = self.detailsText(for: autoService)
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = rows[indexPath.row]
        
        switch row {
        case .cancel:
            let alert = self.cancelAlert()
            present(alert, animated: true, completion: nil)
        default:
            print("nothing")
        }
    }
    
}

extension AutoServiceDetailsViewController: AutoServiceDetailsHeaderViewDelegate {
    
    func present(viewController: UIViewController, header: AutoServiceDetailsHeaderView) {
        present(viewController, animated: true, completion: nil)
    }
    
    func dismissMailComposeViewController(header: AutoServiceDetailsHeaderView) {
        dismiss(animated: true, completion: nil)
    }
    
}
