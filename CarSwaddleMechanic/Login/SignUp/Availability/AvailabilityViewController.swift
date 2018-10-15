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

private let numberOfDays = 7

final class AvailabilityViewController: UIViewController, StoryboardInstantiating {
    
    class func create(with timespans: [TemplateTimeSpan]? = nil) -> AvailabilityViewController {
        let viewController = AvailabilityViewController.viewControllerFromStoryboard()
        if let timespans = timespans {
            viewController.timespans = timespans
        }
        return viewController
    }
    
    private var timespans: [TemplateTimeSpan]!
    

    @IBOutlet private weak var tableView: UITableView!
    
    private var days: [Weekday] = Weekday.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        updateTimespanIfNeeded()
    }
    
    private func updateTimespanIfNeeded() {
        guard timespans == nil else { return }
        timespans = createDefaultTimespans()
    }
    
    private func setupTable() {
        tableView.register(DayCell.self)
        tableView.allowsSelection = false
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
//                let components = DateComponents(day: Int(weekday.rawValue), hour: hour)
//                guard let date = Calendar(identifier: .gregorian).date(from: components) else { continue }
//                timespan.startTime = date
                timespan.startTime = Int64(hour * 60)
                timespan.duration = 60 * 60
                timespan.mechanic = mechanic
                timespan.weekday = weekday
                timespans.append(timespan)
            }
        }
        store.mainContext.persist()
        return timespans
    }
    
    @IBAction func didSelectSave() {
        
    }
    
}

extension AvailabilityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfDays
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DayCell = tableView.dequeueCell()
//        cell.configure(day: days[indexPath.row], hours: )
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
            return existingTimeSpan == timespan
        }
    }
    
    func didAddTimeSpan(_ timespan: TemplateTimeSpan, dayCell: DayCell) {
        timespans.append(timespan)
    }
    
}
