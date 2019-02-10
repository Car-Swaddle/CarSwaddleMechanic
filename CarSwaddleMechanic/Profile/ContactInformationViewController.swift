//
//  ContactInformationViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store

final class ContactInformationViewController: UIViewController, StoryboardInstantiating {

    private enum Row: CaseIterable {
        case email
        case phoneNumber
    }
    
    private var rows: [Row] = Row.allCases
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var currentUser: User? = {
        return User.currentUser(context: store.mainContext)
    }()
    
    private var hasSentVerificationEmail: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(ProfileDataCell.self)
        tableView.register(EmailVerificationCell.self)
        tableView.tableFooterView = UIView()
    }
    
}

extension ContactInformationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .email:
            let cell: EmailVerificationCell = tableView.dequeueCell()
            cell.hasSentVerificationEmail = hasSentVerificationEmail
            cell.didSendVerificationEmail = { [weak self] in
                self?.hasSentVerificationEmail = true
            }
            return cell
        case .phoneNumber:
            let cell: ProfileDataCell = tableView.dequeueCell()
            cell.valueText = currentUser?.phoneNumber ?? NSLocalizedString("No phone number", comment: "")
            cell.descriptionText = nil
            return cell
        }
    }
    
}

extension ContactInformationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

