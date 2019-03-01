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

private let transactionRequestLimit = 40

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
        var predicates: [NSPredicate] = [Transaction.currentMechanicPredicate, Transaction.transactionListPredicate]
        if let payoutID = payoutID {
            let payoutPredicate = Transaction.predicate(forPayoutID: payoutID)
            predicates.append(payoutPredicate)
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: #keyPath(Transaction.availableOn), cacheName: nil)
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
    
    private func requestTransactions(completion: @escaping () -> Void = {}) {
        let lastID = self.lastID
        let payoutID = self.payoutID
        store.privateContext { [weak self] context in
            self?.task = self?.stripeNetwork.requestTransactions(startingAfterID: lastID, payoutID: payoutID, limit: transactionRequestLimit, in: context) { objectIDs, lastID, hasMore, error in
                DispatchQueue.main.async {
                    guard error == nil else { return }
                    self?.lastID = hasMore ? lastID : nil
                    self?.task = nil
                    completion()
                }
            }
        }
    }
    
}


extension TransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = fetchedResultsController.object(at: indexPath)
        
        // Don't show details if it's a payout
        if transaction.transactionType == .payment {
            let viewController = TransactionViewController.create(transaction: transaction)
            show(viewController, sender: self)
        }
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

extension TransactionsViewController: UITableViewDataSource, TransactionCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TransactionCell = tableView.dequeueCell()
        cell.delegate = self
        let transaction = fetchedResultsController.object(at: indexPath)
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TransactionsSectionHeaderView.viewFromNib()
        let transaction = fetchedResultsController.object(at: IndexPath(row: 0, section: section))
        view.availableDate = transaction.availableOn
        return view
    }
    
    func didUpdateHeight(cell: TransactionCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
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



public extension Transaction {
    
    public static var transactionListPredicate: NSPredicate {
        return Transaction.predicate(excluding: [.payout])
    }
    
    public static func predicate(excluding transactionTypes: [Transaction.TransactionType]) -> NSPredicate {
        let types = transactionTypes.map { $0.rawValue }
        return NSPredicate(format: "NOT (%K IN %@)", #keyPath(Transaction.type), types)
    }
    
    public static func predicate(with transactionTypes: [Transaction.TransactionType]) -> NSPredicate {
        let types = transactionTypes.map { $0.rawValue }
        return NSPredicate(format: "%K IN %@", #keyPath(Transaction.type), types)
    }
    
}
