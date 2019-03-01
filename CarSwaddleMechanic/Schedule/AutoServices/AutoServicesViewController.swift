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
import CoreData
import MapKit

let weekdayMonthDayDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, d"
    return dateFormatter
}()

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
            resetData()
            header.date = dayDate
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
    
    private lazy var header: AutoServicesHeaderView = {
        let view = AutoServicesHeaderView.viewFromNib()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        view.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        view.date = self.dayDate
        return view
    }()
    
    private func requestDistanceEstimates() {
        routes.removeAll()
        var previousAutoServiceOptional: AutoService?
        for autoService in fetchedResultsController.fetchedObjects ?? [] {
            guard let sourceLocation = autoService.location?.clLocation,
                let destinationLocation = previousAutoServiceOptional?.location?.clLocation else {
                previousAutoServiceOptional = autoService
                continue
            }
            let routeRequest = RouteRequest(sourceLocation: sourceLocation, destinationLocation: destinationLocation) { [weak self] route, error in
                if let route = route {
                    self?.addRoute(route: route)
                }
            }
            routeRequests.append(routeRequest)
            locationManager.queueRouteRequest(routeRequest: routeRequest)
            previousAutoServiceOptional = autoService
        }
    }
    
    deinit {
        cancelAllRouteRequests()
    }
    
    private func cancelAllRouteRequests() {
        for routeRequest in routeRequests {
            routeRequest.cancel()
        }
    }
    
    private var routeRequests: [RouteRequest] = []
    
    private func addRoute(route: MKRoute) {
        routes.append(route)
        let indexPath = IndexPath(row: routes.count-1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? AutoServiceCell
        cell?.route = route
    }
    
    private var routes: [MKRoute] = []
//    {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestAutoServices()
        updateNoServicesLabelDisplayState()
        NotificationCenter.default.addObserver(self, selector: #selector(AutoServicesViewController.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        requestAutoServices()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AutoServiceCell.self)
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
//        tableView.separatorColor = .clear
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
    }
    
    @objc private func didRefresh() {
        requestAutoServices()
    }
    
    private func requestAutoServices(completion: @escaping () -> Void = {}) {
        guard let currentMechanicID = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.identifier,
            let startDate = startDate,
            let endDate = endDate else {
                completion()
                return
        }
        cancelAllRouteRequests()
        routes = []
        tableView.reloadData()
        task?.cancel()
        store.privateContext { [weak self] privateContext in
            self?.task = self?.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: startDate, endDate: endDate, filterStatus: [.canceled, .inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
                store.mainContext { mainContext in
                    print("autoServices: \(autoServiceIDs.count), date: \(String(describing: self?.dayDate))")
                    self?.resetData()
                    if self?.refreshControl.isRefreshing == true {
                        self?.refreshControl.endRefreshing()
                    }
                    self?.requestDistanceEstimates()
                    completion()
                }
            }
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<AutoService> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<AutoService> {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest()
        fetchRequest.sortDescriptors = [AutoService.mostRecentScheduledDateSort]
        fetchRequest.predicate = AutoService.predicate(startDate: startDate, endDate: endDate)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
        tableView?.reloadData()
        updateNoServicesLabelDisplayState()
        header.dayHasAutoServices = hasAutoServices
    }
    
    private var hasAutoServices: Bool {
        return (fetchedResultsController.sections?[0].numberOfObjects ?? 0) != 0
    }
    
    private func updateNoServicesLabelDisplayState() {
        noDataLabel?.isHidden = hasAutoServices
    }

}

extension AutoServicesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: fetchedResultsController.object(at: indexPath))
        cell.isLastAutoService = self.isLastRow(indexPath: indexPath)
        cell.route = routes.safeObject(at: indexPath.row)
        return cell
    }
    
    private func isLastRow(indexPath: IndexPath) -> Bool {
        return indexPath.row == (fetchedResultsController.sections?[0].numberOfObjects ?? 0)-1
    }
    
}

extension AutoServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let autoServiceViewController = AutoServiceDetailsViewController.create(autoService: fetchedResultsController.object(at: indexPath))
        show(autoServiceViewController, sender: self)
    }
    
}


public extension AutoService {
    
    // MARK: - Predicates
    
    public static func predicate(startDate: Date, endDate: Date) -> NSPredicate {
        return NSPredicate(format: "%@ <= %K && %K <= %@", startDate as NSDate, #keyPath(AutoService.scheduledDate), #keyPath(AutoService.scheduledDate), endDate as NSDate)
    }
    
    // MARK: - Scheduled Date Sort
    
    public static var leastRecentRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: false)
    }
    
    public static var mostRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: true)
    }
    
    public static func scheduledDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.scheduledDate), ascending: ascending)
    }
    
    // MARK: - Creation Date Sort
    
    public static var leastRecentRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: false)
    }
    
    public static var mostRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: true)
    }
    
    public static func creationDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.creationDate), ascending: ascending)
    }
    
}


public extension Location {
    
    public var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
