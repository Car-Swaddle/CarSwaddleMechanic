//
//  PaymentViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/31/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import Store

final class EarningsViewController: UIViewController, StoryboardInstantiating {
    
    private enum Row: CaseIterable {
        case payouts
        case transactions
    }
    
    private var rows: [Row] = Row.allCases
    
    @IBOutlet private weak var tableView: UITableView!
    private var stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    private lazy var header: EarningsHeaderView = {
        let view = EarningsHeaderView.viewFromNib()
        view.configureForEmpty()
        return view
    }()
    
    private lazy var refresh: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(EarningsViewController.didRefresh), for: .valueChanged)
        return view
    }()
    
    @objc private func didRefresh() {
        updateBalance { [weak self] in
            self?.refresh.endRefreshing()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        updateBalance()
    }
    
    private func setupTableView() {
        tableView.tableHeaderView = header
        if let balance = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.balance {
            header.configure(with: balance)
        }
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refresh
        tableView.register(TextCell.self)
    }
    
    private func updateBalance(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.requestBalance(in: privateContext) { balanceID, error in
                store.mainContext { mainContext in
                    defer {
                        completion()
                    }
                    guard let balanceID = balanceID,
                        let balance = mainContext.object(with: balanceID) as? Balance else { return }
                    self?.header.configure(with: balance)
                }
            }
        }
    }

}

extension EarningsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextCell = tableView.dequeueCell()
        let row = rows[indexPath.row]
        cell.textLabel?.text = self.text(for: row)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func text(for row: Row) -> String {
        switch row {
        case .payouts:
            return NSLocalizedString("Payouts", comment: "When selected displays all groups of paid out transactions")
        case .transactions:
            return NSLocalizedString("Transactions", comment: "When selected displays all groups of paid out transactions")
        }
    }
    
}

extension EarningsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .payouts:
            let viewController = PayoutsViewController.viewControllerFromStoryboard()
            show(viewController, sender: self)
        case .transactions:
            let viewController = TransactionsViewController.create(payoutID: nil)
            show(viewController, sender: self)
        }
    }
    
}
