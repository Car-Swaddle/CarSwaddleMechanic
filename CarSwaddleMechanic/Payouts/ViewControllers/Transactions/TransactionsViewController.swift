//
//  TransactionsViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store
import CoreData

private let transactionRequestLimit = 3

final class TransactionsViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    private var task: URLSessionDataTask?
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TransactionsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        lastID = nil
        requestTransactions { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    /// Creates a view controller that displays transactions. If payoutID exists the view controller will
    /// fetch only the transactions for that payout.
    ///
    /// - Parameter payoutID: id of the payout whose transactions will be fetched.
    /// - Returns: The configure Transaction
    static func create(payoutID: String?) -> TransactionsViewController {
        let viewController = TransactionsViewController.viewControllerFromStoryboard()
        viewController.payoutID = payoutID
        return viewController
    }
    
    private var payoutID: String?
    private var lastID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        requestTransactions()
    }
    
    func setupTableView() {
        tableView.register(TransactionCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Transaction> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Transaction> {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [Transaction.createdSortDescriptor]
        fetchRequest.predicate = Transaction.currentMechanicPredicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func reload() {
        tableView.reloadData()
        resetData()
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
    }
    
    private func requestTransactions(completion: @escaping () -> Void = {}) {
        let lastID = self.lastID
        let payoutID = self.payoutID
        store.privateContext { [weak self] context in
            self?.task = self?.stripeNetwork.requestTransaction(startingAfterID: lastID, payoutID: payoutID, limit: transactionRequestLimit, in: context) { objectIDs, lastID, hasMore, error in
                DispatchQueue.main.async {
                    guard error == nil else { return }
                    self?.lastID = hasMore ? lastID : nil
                    self?.reload()
                    self?.task = nil
                    completion()
                }
            }
        }
    }
    
}


extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset
        offset.y += view.frame.height
        guard let indexPath = tableView.indexPathForRow(at: offset),
            let count = fetchedResultsController.fetchedObjects?.count else { return }
        guard indexPath.row >= count-2 else { return }
        guard task == nil && lastID != nil else { return }
        requestTransactions()
    }
    
}

extension TransactionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.fetchedObjects?.count ?? 0
        print(count)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TransactionCell = tableView.dequeueCell()
        
        let transaction = fetchedResultsController.object(at: indexPath)
        cell.configure(with: transaction)
        return cell
    }
    
}

extension TransactionsViewController: NSFetchedResultsControllerDelegate {
    
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


extension Int {
    
    var dollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(self)/100.0)
    }
    
}

