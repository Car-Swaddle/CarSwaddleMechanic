//
//  AvailabilityViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/9/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CoreData
import CarSwaddleData


final class AvailabilityViewController: UIViewController, StoryboardInstantiating {
    
    let network = TemplateTimeSpanNetwork(serviceRequest: serviceRequest)
    
    class func create(shouldCreateDefaultTimeSpans: Bool = false) -> AvailabilityViewController {
        let viewController = AvailabilityViewController.viewControllerFromStoryboard()
        viewController.shouldCreateDefaultTimeSpans = shouldCreateDefaultTimeSpans
        return viewController
    }
    
    private func requestTimeSpans(completion: @escaping () -> Void) {
        store.privateContext { [weak self] context in
            self?.network.getTimeSpans(in: context) { objectIDs, error in
                if objectIDs.count > 0 {
                    store.mainContext { mainContext in
                        let timespans = TemplateTimeSpan.fetchObjects(with: objectIDs, in: mainContext)
                        self?.timespans = timespans
                    }
                } else {
                    completion()
                }
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private var shouldCreateDefaultTimeSpans: Bool = false
    private var days: [Weekday] = Weekday.allCases
    private var timespans: [TemplateTimeSpan] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        requestTimeSpans { [weak self] in
            DispatchQueue.main.async {
                self?.updateTimespansIfNeeded()
            }
        }
        
        updateTimespansIfNeeded()
    }
    
    private func updateTimespansIfNeeded() {
        guard shouldCreateDefaultTimeSpans else { return }
        timespans = createDefaultTimespans()
    }
    
    private func setupTable() {
        tableView.register(DayCell.self)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }
    
    private var defaultHours: [Int] = [9,10,11,12,13,14,15,16,17]
    
    private func createDefaultTimespans() -> [TemplateTimeSpan] {
        guard let userID = User.currentUserID,
            let mechanic = Mechanic.fetch(with: userID, in: store.mainContext) else { return [] }
        guard mechanic.scheduleTimeSpans.count == 0 else {
            return Array(mechanic.scheduleTimeSpans)
        }
        var timespans: [TemplateTimeSpan] = []
        for weekday in Weekday.allCases {
            for hour in defaultHours {
                let timespan = TemplateTimeSpan(context: store.mainContext)
                timespan.identifier = UUID().uuidString
                timespan.startTime = Int64(hour * 60)
                timespan.duration = .hour
                timespan.mechanic = mechanic
                timespan.weekday = weekday
                timespans.append(timespan)
            }
        }
        store.mainContext.persist()
        return timespans
    }
    
    @IBAction func didSelectSave() {
        
        let previousButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem.activityBarButtonItem(with: .gray)
        
        let timeSpanObjectIDs = timespans.map { $0.objectID }
        store.privateContext { [weak self] context in
            let privateFetchedSpans = TemplateTimeSpan.fetchObjects(with: timeSpanObjectIDs, in: context)
            self?.network.postTimeSpans(templateTimeSpans: privateFetchedSpans, in: context) { objectIDs, error in
                store.mainContext { mainContext in
                    self?.navigationItem.rightBarButtonItem = previousButton
                    let newSpans = TemplateTimeSpan.fetchObjects(with: objectIDs, in: mainContext)
                    self?.timespans = newSpans
                }
            }
        }
    }
    
}

extension AvailabilityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DayCell = tableView.dequeueCell()
        cell.delegate = self
        let day = days[indexPath.row]
        cell.configure(day: day, timespans: timespans(for: day))
        cell.layoutIfNeeded()
        return cell
    }
    
    private func timespans(for day: Weekday) -> [TemplateTimeSpan] {
        return timespans.filter { timeSpan -> Bool in
            return timeSpan.weekday == day
        }
    }
    
}

extension AvailabilityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
    }
    
}

extension AvailabilityViewController: DayCellDelegate {
    
    func didDeleteTemplateTimeSpan(_ timespan: TemplateTimeSpan, dayCell: DayCell) {
        timespans.removeAll { existingTimeSpan -> Bool in
            return existingTimeSpan.identifier == timespan.identifier
        }
    }
    
    func didAddTimeSpan(_ timespan: TemplateTimeSpan, dayCell: DayCell) {
        timespans.append(timespan)
    }
    
}
