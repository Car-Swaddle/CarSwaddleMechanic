//
//  PayoutsViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store
import CoreData

private let requestLimit = 30

final class PayoutsViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    private var lastID: String?
    private var task: URLSessionDataTask?
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(PayoutsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        requestData()
        
//        if Payout.fetch(with: "something", in: store.mainContext) == nil {
//            let payout = Payout(context: store.mainContext)
//            payout.identifier = "something" // : String
//            payout.amount = 34689 // : Int
//            payout.arrivalDate = Date().dateByAdding(days: 4)! // : Date
//            payout.created = Date().dayAfter! // : Date
//            payout.currency = "usd" // : String
//            payout.payoutDescription = "Your Payout for the oil changes"
//            payout.destination = "sr_345678"
//            payout.type = "card"
//            payout.method = "standard"
//            payout.sourceType = "bank_account"
//            payout.mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext)
//            payout.status = .paid
////            payout.failureMessage = "This is a failure message"
//
//            store.mainContext.persist()
//        }
    }
    
    private func setupTableView() {
        tableView.register(PayoutCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    @objc private func didRefresh() {
        lastID = nil
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Payout> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Payout> {
        let fetchRequest: NSFetchRequest<Payout> = Payout.fetchRequest()
        fetchRequest.sortDescriptors = [Payout.arrivalDateSortDescriptor]
        fetchRequest.predicate = Payout.currentMechanicPredicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func reload() {
        resetData()
        tableView.reloadData()
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.stripeNetwork.requestPayouts(startingAfterID: self?.lastID, limit: requestLimit, in: context) { objectIDs, lastID, hasMore, error in
                DispatchQueue.main.async {
                    self?.lastID = hasMore ? lastID : nil
                    self?.task = nil
                    completion()
                }
            }
        }
    }
    
}

extension PayoutsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PayoutCell = tableView.dequeueCell()
        let payout = fetchedResultsController.object(at: indexPath)
        cell.configure(with: payout)
        return cell
    }
    
}

extension PayoutsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payout = fetchedResultsController.object(at: indexPath)
        let viewController = TransactionsViewController.create(payoutID: payout.identifier)
        show(viewController, sender: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset
        offset.y += view.frame.height
        guard let indexPath = tableView.indexPathForRow(at: offset),
            let count = fetchedResultsController.fetchedObjects?.count else { return }
        guard indexPath.row >= count-2 else { return }
        guard task == nil && lastID != nil else { return }
        requestData()
    }
    
}

extension PayoutsViewController: NSFetchedResultsControllerDelegate {
    
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
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
