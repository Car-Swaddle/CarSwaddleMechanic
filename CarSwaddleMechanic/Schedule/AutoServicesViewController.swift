//
//  AutoServicesViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/17/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store

final class AutoServicesViewController: UIViewController, StoryboardInstantiating {

    static func create(date: Date) -> AutoServicesViewController {
        let viewController = AutoServicesViewController.viewControllerFromStoryboard()
        viewController.dayDate = date
        return viewController
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var dayDate: Date! {
        didSet {
            startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: dayDate)
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dayDate)
//            updateDateLabelIfNeeded()
            autoServices = []
            requestAutoServices()
            
//            if viewIfLoaded != nil {
//                weekView.select(dayDate)
//            }
        }
    }
    private var startDate: Date!
    private var endDate: Date!
    
    @IBOutlet private weak var noDataLabel: UILabel!
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var task: URLSessionDataTask?
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addRefreshTarget(target: self, action: #selector(AutoServicesViewController.didRefresh))
        return refresh
    }()
    
    private var autoServices: [AutoService] = [] {
        didSet {
            guard viewIfLoaded != nil else { return }
            tableView.reloadData()
            noDataLabel.isHidden = autoServices.count != 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestAutoServices()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    @objc private func didRefresh() {
        requestAutoServices()
//        requestAutoServices { [weak self] in
//            DispatchQueue.main.async {
//                self?.refreshControl.endRefreshing()
//            }
//        }
    }
    
    private func requestAutoServices(completion: @escaping () -> Void = {}) {
        guard let currentMechanicID = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier,
            let startDate = startDate,
            let endDate = endDate else {
                completion()
                return
        }
        task?.cancel()
        store.privateContext { [weak self] privateContext in
            self?.task = self?.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: startDate, endDate: endDate, filterStatus: [.canceled, .inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
                store.mainContext { mainContext in
                    self?.autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                    completion()
                }
            }
        }
    }

}

extension AutoServicesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: autoServices[indexPath.row])
        return cell
    }
    
}

extension AutoServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoServiceViewController = AutoServiceDetailsViewController.create(autoService: autoServices[indexPath.row])
        show(autoServiceViewController, sender: self)
    }
    
}
