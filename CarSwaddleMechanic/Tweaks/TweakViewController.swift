//
//  TweakViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/27/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class TweakViewController: UIViewController, StoryboardInstantiating {

    
    @IBOutlet private weak var tableView: UITableView!
    
    private var tweaks: [Tweak] = Tweak.all
    private var resetAppOnDismiss: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(TweakStringValueCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func didSelectDone(_ button: UIBarButtonItem) {
        let shouldReset = resetAppOnDismiss
        dismiss(animated: true) {
            if shouldReset {
                logout.logout()
            }
        }
    }
}

extension TweakViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweaks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweakStringValueCell = tableView.dequeueCell()
        
        let tweak = tweaks[indexPath.row]
        cell.configure(with: tweak)
        return cell
    }
    
}

extension TweakViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected tweak: \(tweaks[indexPath.row])")
        let viewController = TweakSelectViewController.create(with: tweaks[indexPath.row])
        viewController.delegate = self
        show(viewController, sender: true)
    }
    
}

extension TweakViewController: TweakSelectDelegate {
    
    func didChangeValue(tweak: Tweak, newValue: Any?, tweakSelectViewController: TweakSelectViewController) {
        resetAppOnDismiss = tweak.requiresAppReset
        tableView.reloadData()
    }
    
}
