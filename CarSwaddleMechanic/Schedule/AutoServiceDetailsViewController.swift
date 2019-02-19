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


final class AutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {
    
    public static func create(autoServiceID: String) -> AutoServiceDetailsViewController {
        let viewController = AutoServiceDetailsViewController.viewControllerFromStoryboard()
        if let autoService = AutoService.fetch(with: autoServiceID, in: store.mainContext) {
            viewController.autoService = autoService
        } else {
            viewController.autoServiceID = autoServiceID
        }
        return viewController
    }
    
    public static func create(autoService: AutoService) -> AutoServiceDetailsViewController {
        let viewController = AutoServiceDetailsViewController.viewControllerFromStoryboard()
        viewController.autoService = autoService
        return viewController
    }
    
    enum Row {
        case date
        case user
        case mechanic
        case location
        case vehicle
        case serviceType
        case oilType
        case autoServiceStatus
    }
    
    private var rows: [Row] = [.date, .user, .mechanic, .location, .vehicle, .serviceType, .oilType, .autoServiceStatus]
    private var autoServiceID: String?
    private var autoService: AutoService? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if autoServiceID != nil && autoService == nil {
            requestData()
        }
        
        setupTableView()
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
                    if let autoServiceObjectID = autoServiceObjectID, error == nil {
                        self?.autoService = mainContext.object(with: autoServiceObjectID) as? AutoService
                    }
                }
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceItemCell.self)
        tableView.register(AutoServiceLocationCell.self)
        tableView.register(AutoServiceStatusCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func text(for row: Row) -> String? {
        switch row {
        case .date:
            if let scheduledDate = autoService?.scheduledDate {
                return dayOfWeekMonthDayTimeDateFormatter.string(from: scheduledDate)
            }
            return nil
        case .user: return autoService?.creator?.displayName
        case .mechanic: return autoService?.mechanic?.user?.displayName
        case .location: return autoService?.location?.streetAddress
        case .vehicle: return autoService?.vehicle?.name
        case .serviceType: return autoService?.serviceEntities.first?.entityType.localizedString
        case .oilType: return autoService?.serviceEntities.first?.oilChange?.oilType.localizedString
        case .autoServiceStatus: return autoService?.status.localizedString
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
        case .date, .mechanic, .serviceType, .user, .vehicle, .oilType:
            let cell: AutoServiceItemCell = tableView.dequeueCell()
            let autoService = rows[indexPath.row]
            cell.titleText = self.text(for: autoService)
            cell.subtitleText = self.detailsText(for: autoService)
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    
    
}
