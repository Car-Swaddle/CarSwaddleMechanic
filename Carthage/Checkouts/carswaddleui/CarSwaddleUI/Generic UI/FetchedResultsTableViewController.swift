//
//  FetchedResultsTableViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CoreData


public enum FetchedResultsControllerUpdateType {
    case reloadAlways
    case individual
}

open class FetchedResultsTableViewController<T: NSFetchRequestResult>: PagingTableViewController, NSFetchedResultsControllerDelegate {
    
    open var updateType: FetchedResultsControllerUpdateType = .individual
    
    private func didResetFetchedResultsController() {
        tableView.reloadData()
    }
    
    lazy private(set) open var fetchedResultsController: NSFetchedResultsController<T> = {
        return createFetchedResultsController()
    }()
    
    open var fetchRequest: NSFetchRequest<T>! {
        fatalError("subclass must override this property and return a value")
    }
    open var context: NSManagedObjectContext! {
        fatalError("subclass must override this property and return a value")
    }
    
    open var sectionNameKeyPath: String? { return nil }
    open var cacheName: String? { return nil }
    
    final public func resetFetchedResultsController() {
        self.fetchedResultsController = createFetchedResultsController()
        didResetFetchedResultsController()
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<T> {
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            fatalError("Could not performFetch on FetchedResultsController, error: \(error.localizedDescription)")
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.refreshControl = refreshControl
    }
    
    // MARK: Convenience
    
    final public func object(at indexPath: IndexPath) -> T {
        return fetchedResultsController.object(at: indexPath)
    }
    
    final public func indexPath(forObject object: T) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    final public func count(for section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard updateType == .individual else { return }
        switch type {
        case .insert:
            guard let insertIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [insertIndexPath], with: .automatic)
        case .delete:
            guard let deleteIndexPath = indexPath else { return }
            tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        case .update:
            guard let updateIndexPath = indexPath else { return }
            tableView.reloadRows(at: [updateIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            break
        }
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        guard updateType == .individual else { return }
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            break
        @unknown default:
            break
        }
    }
    
    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch updateType {
        case .individual:
            tableView.beginUpdates()
        case .reloadAlways:
            break
        }
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch updateType {
        case .individual:
            tableView.endUpdates()
        case .reloadAlways:
            tableView.reloadData()
        }
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    
    // MARK: - Tableview Datasource
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Either override this method, or override cell(for object: T, indexPath: IndexPath)
        return cell(for: object(at: indexPath), indexPath: indexPath)
    }
    
    open func cell(for object: T, indexPath: IndexPath) -> UITableViewCell {
        fatalError("Must override this method of the default cellForRowAt UITableViewDataSource method")
    }
    
}


