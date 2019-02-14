//
//  TaxesViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store
import CoreData


final class TaxesViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var tableView: UITableView!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TaxesViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private var currentMechanic: Mechanic {
        return Mechanic.currentLoggedInMechanic(in: store.mainContext)!
    }
    
    private var taxNetwork: TaxNetwork = TaxNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        requestData()
    }
    
    private func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.register(TaxYearCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.taxNetwork.requestTaxYears(in: context) { taxInfoObjectIDs, error in
                DispatchQueue.main.async {
                    self?.resetData()
                    self?.tableView.reloadData()
                    completion()
                }
            }
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TaxInfo> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<TaxInfo> {
        let fetchRequest: NSFetchRequest<TaxInfo> = TaxInfo.fetchRequest(for: currentMechanic)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
    }
    
}


extension TaxesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TaxYearCell = tableView.dequeueCell()
        
        let taxInfo = fetchedResultsController.object(at: indexPath)
        cell.configure(with: taxInfo)
        return cell
    }
    
}

extension TaxesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select table view")
    }
    
}
