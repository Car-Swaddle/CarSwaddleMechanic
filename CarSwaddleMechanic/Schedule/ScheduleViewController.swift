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
    
    @IBOutlet private weak var viewControllerContentView: UIView!
    
    //    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet weak var weekView: FSCalendar!
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    @IBOutlet weak var weekViewHeightConstraint: NSLayoutConstraint!
//    private var task: URLSessionDataTask?
    
//    lazy private var refreshControl: UIRefreshControl = {
//        let refresh = UIRefreshControl(frame: .zero)
//        refresh.addRefreshTarget(target: self, action: #selector(ScheduleViewController.didRefresh))
//        return refresh
//    }()
    
//    private var autoServices: [AutoService] = [] {
//        didSet {
//            guard viewIfLoaded != nil else { return }
//            tableView.reloadData()
//        }
//    }
    
    private var dayDate: Date! {
        didSet {
            startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: dayDate)
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dayDate)
            updateDateLabelIfNeeded()
//            autoServices = []
//            requestAutoServices()
            if viewIfLoaded != nil {
//                weekView.select(dayDate)
            }
            
            if let previousDate = (pageViewController.viewControllers?.first as? AutoServicesViewController)?.dayDate,
                Calendar.current.isDate(previousDate, inSameDayAs: dayDate) == false {
                DispatchQueue.main.async {
                    let autoServicesViewController = AutoServicesViewController.create(date: self.dayDate)
                    if previousDate > self.dayDate {
                        self.pageViewController.setViewControllers([autoServicesViewController], direction: .reverse, animated: true, completion: nil)
                    } else {
                        self.pageViewController.setViewControllers([autoServicesViewController], direction: .forward, animated: true, completion: nil)
                    }
                }
            } else {
                (pageViewController.viewControllers?.first as? AutoServicesViewController)?.dayDate = dayDate
            }
            
//            (pageViewController.viewControllers?.first as? AutoServicesViewController)?.dayDate = dayDate
        }
    }
    private var startDate: Date!
    private var endDate: Date!
    
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        return pageViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupTableView()
//        requestAutoServices()
        updateDateLabelIfNeeded()
        
        weekView.setScope(.week, animated: false)
        weekView.appearance.weekdayFont = UIFont.appFont(type: .semiBold, size: 14)
        weekView.appearance.titleFont = UIFont.appFont(type: .semiBold, size: 16)
        
        if viewIfLoaded != nil {
            weekView.select(dayDate)
        }
        
        weekView.addHairlineView(toSide: .bottom, color: UIColor(white: 0.6, alpha: 1.0), size: 1.0 / UIScreen.main.scale)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let autoServicesViewController = AutoServicesViewController.create(date: Date())
        
        pageViewController.setViewControllers([autoServicesViewController], direction: .forward, animated: false, completion: nil)
        
        addChild(pageViewController)
        viewControllerContentView.addSubview(pageViewController.view)
        
        pageViewController.view.frame = viewControllerContentView.bounds
        pageViewController.didMove(toParent: self)
        
        view.gestureRecognizers = pageViewController.gestureRecognizers
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController.view.frame = viewControllerContentView.bounds
    }
    
    private func updateDateLabelIfNeeded() {
        guard viewIfLoaded != nil else { return }
        navigationItem.title = monthDayYearDateFormatter.string(from: dayDate)
    }
    
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(AutoServiceCell.self)
//        tableView.tableFooterView = UIView()
//        tableView.refreshControl = refreshControl
//    }
    
//    @objc private func didRefresh() {
//        requestAutoServices { [weak self] in
//            DispatchQueue.main.async {
//                self?.refreshControl.endRefreshing()
//            }
//        }
//    }
    
    @IBAction private func didTapLeft() {
        dayDate = dayDate.dayBefore ?? dayDate
    }
    
    @IBAction private func didTapRight() {
        dayDate = dayDate.dayAfter ?? dayDate
    }
    
//    private func requestAutoServices(completion: @escaping () -> Void = {}) {
//        guard let currentMechanicID = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier,
//            let startDate = startDate,
//            let endDate = endDate else {
//                completion()
//                return
//        }
//        task?.cancel()
//        store.privateContext { [weak self] privateContext in
//            self?.task = self?.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: startDate, endDate: endDate, filterStatus: [.canceled, .inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
//                store.mainContext { mainContext in
//                    self?.autoServices = AutoService.fetchObjects(with: autoServiceIDs, in: mainContext)
//                    completion()
//                }
//            }
//        }
//    }
    
}

extension ScheduleViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let previousDay = (viewController as? AutoServicesViewController)?.dayDate.dateByAdding(days: -1) else {
            return nil
        }
        let autoServicesViewController = AutoServicesViewController.create(date: previousDay)
        return autoServicesViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let nextDay = (viewController as? AutoServicesViewController)?.dayDate.dateByAdding(days: 1) else {
            return nil
        }
        let autoServicesViewController = AutoServicesViewController.create(date: nextDay)
        return autoServicesViewController
    }
    
}

extension ScheduleViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        if let date = (pageViewController.viewControllers?.first as? AutoServicesViewController)?.dayDate {
//            weekView.select(date)
//        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let date = (pageViewController.viewControllers?.first as? AutoServicesViewController)?.dayDate {
            weekView.select(date, scrollToDate: true)
        }
    }
    
}


//extension ScheduleViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return autoServices.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: AutoServiceCell = tableView.dequeueCell()
//        cell.configure(with: autoServices[indexPath.row])
//        return cell
//    }
//
//}
//
//extension ScheduleViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let autoServiceViewController = AutoServiceDetailsViewController.create(autoService: autoServices[indexPath.row])
//        show(autoServiceViewController, sender: self)
//    }
//
//}

extension ScheduleViewController: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if let selectedDayOfWeek = calendar.selectedDate?.dayOfWeek,
            let newDate = calendar.currentPage.dateByAdding(days: selectedDayOfWeek-1) {
            dayDate = newDate
            weekView.select(newDate)
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
