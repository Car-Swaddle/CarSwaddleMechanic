//
//  TweakViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/27/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public protocol TweakViewControllerDelegate: AnyObject {
    func didDismiss(requiresAppReset: Bool, tweakViewController: TweakViewController)
}

final public class TweakViewController: UIViewController, StoryboardInstantiating {
    
    public class func create(with tweaks: [Tweak], delegate: TweakViewControllerDelegate? = nil) -> TweakViewController {
        let viewController = TweakViewController.viewControllerFromStoryboard()
        viewController.tweaks = tweaks
        viewController.delegate = delegate
        return viewController
    }
    
    public weak var delegate: TweakViewControllerDelegate?
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var tweaks: [Tweak] = []
    private var resetAppOnDismiss: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(TweakStringValueCell.self)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func didSelectDone(_ button: UIBarButtonItem) {
        let shouldReset = resetAppOnDismiss
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.didDismiss(requiresAppReset: shouldReset, tweakViewController: self)
        }
    }
}

extension TweakViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweaks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweakStringValueCell = tableView.dequeueCell()
        
        let tweak = tweaks[indexPath.row]
        cell.configure(with: tweak)
        return cell
    }
    
}

extension TweakViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
