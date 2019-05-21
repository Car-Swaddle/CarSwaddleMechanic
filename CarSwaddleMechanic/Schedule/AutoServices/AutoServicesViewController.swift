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

    enum Section: Int {
        case scheduled
        case canceled
    }
    
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
        let objects = fetchedResultsController.sections?.safeObject(at: 0)?.objects ?? []
        for object in objects {
            guard let autoService = object as? AutoService else { continue }
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
        fetchedResultsController.delegate = nil
        store.privateContext { [weak self] privateContext in
            self?.task = self?.autoServiceNetwork.getAutoServices(mechanicID: currentMechanicID, startDate: startDate, endDate: endDate, filterStatus: [.canceled, .inProgress, .completed, .scheduled], in: privateContext) { autoServiceIDs, error in
                store.mainContext { mainContext in
                    guard let self = self else { return }
                    self.resetData()
                    self.fetchedResultsController.delegate = self
                    if self.refreshControl.isRefreshing == true {
                        self.refreshControl.endRefreshing()
                    }
                    self.requestDistanceEstimates()
                    completion()
                }
            }
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<AutoService> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<AutoService> {
        let fetchRequest: NSFetchRequest<AutoService> = AutoService.fetchRequest()
        fetchRequest.sortDescriptors = [AutoService.isCanceledSort, AutoService.mostRecentScheduledDateSort]
        fetchRequest.predicate = AutoService.predicate(startDate: startDate, endDate: endDate)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: #keyPath(AutoService.isCanceled), cacheName: nil)
        try! fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
        tableView?.reloadData()
        updateNoServicesLabelDisplayState()
        header.dayHasAutoServices = hasAutoServices
    }
    
    private var hasAutoServices: Bool {
//        return (fetchedResultsController.sections?[0].numberOfObjects ?? 0) != 0
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    private func updateNoServicesLabelDisplayState() {
        noDataLabel?.isHidden = hasAutoServices
    }

}

extension AutoServicesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AutoServiceCell = tableView.dequeueCell()
        cell.configure(with: fetchedResultsController.object(at: indexPath))
        cell.isLastAutoService = self.isLastRow(indexPath: indexPath)
        
        if section(fromSectionIndex: indexPath.section) == .scheduled {
            cell.route = routes.safeObject(at: indexPath.row)
        } else {
            cell.route = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionIndex: Int) -> CGFloat {
        switch self.section(fromSectionIndex: sectionIndex) {
        case .scheduled: return 0
        case .canceled: return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        switch self.section(fromSectionIndex: sectionIndex) {
        case .scheduled:
            return nil
        case .canceled:
            let header = HeaderView()
            header.labelText = NSLocalizedString("Canceled auto services", comment: "Title of header")
            return header
        }
    }
    
    private func section(fromSectionIndex sectionIndex: Int) -> Section {
        guard let section = Section(rawValue: sectionIndex) else {
            fatalError("Should not have section: \(sectionIndex)")
        }
        return section
    }
    
    private func isLastRow(indexPath: IndexPath) -> Bool {
        return indexPath.row == (fetchedResultsController.sections?.safeObject(at: 0)?.numberOfObjects ?? 0)-1
    }
    
}

extension AutoServicesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let autoServiceViewController = AutoServiceDetailsViewController.create(autoService: fetchedResultsController.object(at: indexPath))
        show(autoServiceViewController, sender: self)
    }
    
}

extension AutoServicesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        @unknown default:
            fatalError("unkown case")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


public extension AutoService {
    
    // MARK: - Predicates
    
    static func predicate(startDate: Date, endDate: Date) -> NSPredicate {
        return NSPredicate(format: "%@ <= %K && %K <= %@", startDate as NSDate, #keyPath(AutoService.scheduledDate), #keyPath(AutoService.scheduledDate), endDate as NSDate)
    }
    
    // MARK: - Scheduled Date Sort
    
    static var leastRecentRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: false)
    }
    
    static var mostRecentScheduledDateSort: NSSortDescriptor {
        return AutoService.scheduledDateSort(ascending: true)
    }
    
    static func scheduledDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.scheduledDate), ascending: ascending)
    }
    
    // MARK: - Creation Date Sort
    
    static var leastRecentRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: false)
    }
    
    static var mostRecentCreationDateSort: NSSortDescriptor {
        return AutoService.creationDateSort(ascending: true)
    }
    
    static func creationDateSort(ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.creationDate), ascending: ascending)
    }
    
    // MARK: -
    
    static var isCanceledSort: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(AutoService.isCanceled), ascending: true)
    }
    
}


public extension Location {
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}


public extension Array {
    
    func safeObject(at index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
    
}
