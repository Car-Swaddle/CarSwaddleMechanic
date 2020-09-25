//
//  ReviewsViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest
import CarSwaddleStore
import CoreData
import UIKit

private let reviewPageLimit = 30

final class ReviewsViewController: UIViewController, StoryboardInstantiating {

    private var reviewNetwork: ReviewNetwork = ReviewNetwork(serviceRequest: serviceRequest)
    private var task: URLSessionDataTask?
    private var numberOfFetchedReviews: Int = 0
    private var hasMore: Bool = false
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(ReviewsViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestData()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(ReviewListCell.self)
        tableView.refreshControl = refreshControl
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<Review> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<Review> {
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.sortDescriptors = [Review.creationDateSortDescriptor]
        fetchRequest.predicate = Review.predicateForCurrentMechanic()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func reloadData() {
        fetchedResultsController = createFetchedResultsController()
        tableView.reloadData()
    }
    
    private func requestData(completion: @escaping () -> Void = {  }) {
        guard let mechanicID = Mechanic.currentMechanicID else {
            completion()
            return
        }
        let offset = numberOfFetchedReviews
        store.privateContext { [weak self] privateContext in
            self?.task = self?.reviewNetwork.getReviews(forMechanicWithID: mechanicID, limit: reviewPageLimit, offset: offset, in: privateContext) { reviewIDs, error in
                DispatchQueue.main.async {
                    self?.reloadData()
                    completion()
                    self?.task = nil
                    self?.hasMore = reviewIDs.count == reviewPageLimit
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset
        offset.y += view.frame.height
        guard let indexPath = tableView.indexPathForRow(at: offset),
            let count = fetchedResultsController.fetchedObjects?.count else { return }
        guard indexPath.row >= count-2 else { return }
        guard task == nil && hasMore else { return }
        requestData()
    }
    
}

extension ReviewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReviewListCell = tableView.dequeueCell()
        let review = fetchedResultsController.object(at: indexPath)
        cell.configure(with: review)
        return cell
    }
    
}

extension ReviewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select review")
    }
    
}

extension ReviewsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            fatalError("unkown case")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
