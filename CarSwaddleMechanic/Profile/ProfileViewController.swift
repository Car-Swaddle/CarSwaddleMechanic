//
//  ProfileViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

final class ProfileViewController: UIViewController, StoryboardInstantiating {
    
    enum Row: CaseIterable {
        case serviceRegion
        
    }
    
    private var rows: [Row] = Row.allCases

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileServiceRegionCell.self)
    }
    
    @IBAction func didSelectEditSchedule() {
        let availability = AvailabilityViewController.create(with: <#T##[TemplateTimeSpan]?#>)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        
        switch row {
        case .serviceRegion:
            let serviceRegion = ServiceRegionViewController.viewControllerFromStoryboard()
            show(serviceRegion, sender: self)
        }
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileServiceRegionCell = tableView.dequeueCell()
        if let region = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.serviceRegion {
            cell.configure(with: region)
        }
        return cell
    }
    
    
}
