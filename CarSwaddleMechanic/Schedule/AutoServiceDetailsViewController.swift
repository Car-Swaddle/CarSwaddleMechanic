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


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d h:mm a"
    return formatter
}()

final class AutoServiceDetailsViewController: UIViewController, StoryboardInstantiating {
    
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
    private var autoService: AutoService!
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
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
            if let scheduledDate = autoService.scheduledDate {
                return dateFormatter.string(from: scheduledDate)
            }
            return nil
        case .user: return autoService.creator?.displayName
        case .mechanic: return autoService.mechanic?.user?.displayName
        case .location: return autoService.location?.streetAddress
        case .vehicle: return autoService.vehicle?.name
        case .serviceType: return autoService.serviceEntities.first?.entityType.localizedString
        case .oilType: return autoService.serviceEntities.first?.oilChange?.oilType.localizedString
        case .autoServiceStatus: return autoService.status.localizedString
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
            if let location = autoService.location {
                cell.configure(with: location)
            }
            return cell
        case .autoServiceStatus:
            let cell: AutoServiceStatusCell = tableView.dequeueCell()
            cell.configure(with: autoService)
            return cell
        case .date, .mechanic, .serviceType, .user, .vehicle, .oilType:
            let cell: AutoServiceItemCell = tableView.dequeueCell()
            cell.textLabel?.text = self.text(for: rows[indexPath.row])
            return cell
        }
    }
    
}

extension AutoServiceDetailsViewController: UITableViewDelegate {
    
    
    
}



extension OilType {
    
    var localizedString: String {
        switch self {
        case .blend: return NSLocalizedString("blend", comment: "synthetic blend oil type")
        case .conventional: return NSLocalizedString("conventional", comment: "conventional oil type")
        case .synthetic: return NSLocalizedString("synthetic", comment: "synthetic oil type")
        }
    }
    
}


extension AutoService.Status {
    
    var localizedString: String {
        switch self {
        case .canceled: return NSLocalizedString("canceled", comment: "auto service status")
        case .inProgress: return NSLocalizedString("in progress", comment: "auto service status")
        case .completed: return NSLocalizedString("completed", comment: "auto service status")
        case .scheduled: return NSLocalizedString("scheduled", comment: "auto service status")
        }
    }
    
}
