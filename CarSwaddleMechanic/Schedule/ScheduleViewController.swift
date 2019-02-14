//
//  ScheduleViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import CarSwaddleNetworkRequest
import Store


final class ScheduleViewController: UIViewController, StoryboardInstantiating {
    
    public class func scheduleViewController(for date: Date) -> ScheduleViewController {
        let viewController = ScheduleViewController.viewControllerFromStoryboard()
        viewController.dayDate = date
        return viewController
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var task: URLSessionDataTask?
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addRefreshTarget(target: self, action: #selector(ScheduleViewController.didRefresh))
        return refresh
    }()
    
    private var autoServices: [AutoService] = [] {
        didSet {
            guard viewIfLoaded != nil else { return }
            tableView.reloadData()
        }
    }
    
    private var dayDate: Date! {
        didSet {
            startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: dayDate)
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dayDate)
            updateDateLabelIfNeeded()
            autoServices = []
            requestAutoServices()
        }
    }
    private var startDate: Date!
    private var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestAutoServices()
        updateDateLabelIfNeeded()
    }
    
    private func updateDateLabelIfNeeded() {
        guard viewIfLoaded != nil else { return }
        title = dateFormatter.string(from: dayDate)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    @objc private func didRefresh() {
        requestAutoServices { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction private func didTapLeft() {
        dayDate = dayDate.dayBefore ?? dayDate
    }
    
    @IBAction private func didTapRight() {
        dayDate = dayDate.dayAfter ?? dayDate
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
                    completion()
                }
            }
        }
    }
    
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: autoServices[indexPath.row])
        return cell
    }
    
}

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let autoServiceViewController = AutoServiceDetailsViewController.create(autoService: autoServices[indexPath.row])
        show(autoServiceViewController, sender: self)
    }
    
}
