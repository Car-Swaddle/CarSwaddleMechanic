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
import FSCalendar

let monthYearDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
}()


final class ScheduleViewController: UIViewController, StoryboardInstantiating {
    
    public class func scheduleViewController(for date: Date) -> ScheduleViewController {
        let viewController = ScheduleViewController.viewControllerFromStoryboard()
        viewController.dayDate = date
        return viewController
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet weak var weekView: FSCalendar!
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet weak var weekViewHeightConstraint: NSLayoutConstraint!
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
            if viewIfLoaded != nil {
                weekView.select(dayDate)
            }
        }
    }
    private var startDate: Date!
    private var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestAutoServices()
        updateDateLabelIfNeeded()
        
        weekView.setScope(.week, animated: false)
        weekView.appearance.weekdayFont = UIFont.appFont(type: .regular, size: 14)
        weekView.appearance.weekdayFont = UIFont.appFont(type: .regular, size: 12)
        weekView.appearance.titleFont = UIFont.appFont(type: .regular, size: 16)
        
        if viewIfLoaded != nil {
            weekView.select(dayDate)
        }
        
        weekView.addHairlineView(toSide: .bottom, color: UIColor(white: 0.6, alpha: 1.0), size: 1.0 / UIScreen.main.scale)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func updateDateLabelIfNeeded() {
        guard viewIfLoaded != nil else { return }
        navigationItem.title = monthDayYearDateFormatter.string(from: dayDate)
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

extension ScheduleViewController: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("page: \(calendar.currentPage)")
        if let selectedDayOfWeek = calendar.selectedDate?.dayOfWeek,
            let newDate = calendar.currentPage.dateByAdding(days: selectedDayOfWeek-1) {
//            calendar.select(newDate)
            dayDate = newDate
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dayDate = date
    }
    
}

extension ScheduleViewController: FSCalendarDataSource {
    
}

extension ScheduleViewController: FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return .red1
        } else {
            return .black
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return .textColor1
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        weekViewHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
//        return .viewBackgroundColor1
//    }
    
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
//        return .white
//    }
    
}
