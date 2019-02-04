//
//  TweakSelectViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/27/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

protocol TweakSelectDelegate: AnyObject {
    func didChangeValue(tweak: Tweak, newValue: Any?, tweakSelectViewController: TweakSelectViewController)
}


final class TweakSelectViewController: UIViewController, StoryboardInstantiating {
    
    weak var delegate: TweakSelectDelegate?
    
    static func create(with tweak: Tweak) -> TweakSelectViewController {
        switch tweak.options {
        case .bool: fatalError("bool not supported")
        case .openString: fatalError("open String not supported")
        case .openInt: fatalError("open Int not supported")
        case .integer(_): break
        case .string(_): break
        }
        
        let viewController = TweakSelectViewController.viewControllerFromStoryboard()
        viewController.tweak = tweak
        return viewController
    }
    
    private var selectedIndex: Int? {
        didSet {
            updateUIForSelectedIndex()
        }
    }
    
    private func updateUIForSelectedIndex() {
        tableView?.visibleCells.forEach { $0.accessoryType = .none }
        if let selectedIndex = selectedIndex {
            let cell = tableView?.cellForRow(at: IndexPath(row: selectedIndex, section: 0))
            cell?.accessoryType = .checkmark
        }
    }
    
    private var tweak: Tweak! {
        didSet {
            self.options = tweak?.options
        }
    }
    
    private var options: Tweak.Options? {
        didSet {
            if let intValues = intValues {
                if let tweakIntValue = tweak?.value as? Int {
                    selectedIndex = intValues.firstIndex(of: tweakIntValue)
                }
            } else if let stringValues = stringValues {
                if let tweakStringValue = tweak?.value as? String {
                    selectedIndex = stringValues.firstIndex(of: tweakStringValue)
                }
            }
        }
    }
    
    private var numberOfValues: Int {
        guard let options = options else { return 0 }
        switch options {
        case .bool: fatalError("bool not supported")
        case .openString: fatalError("open String not supported")
        case .openInt: fatalError("open Int not supported")
        case .integer(let values): return values.count
        case .string(let values): return values.count
        }
    }
    
    private var stringValues: [String]? {
        guard let options = options else { fatalError("Must have options") }
        switch options {
        case .bool: fatalError("bool not supported")
        case .openString: fatalError("open String not supported")
        case .openInt: fatalError("open Int not supported")
        case .integer(_): return nil
        case .string(let values): return values
        }
    }
    
    private var intValues: [Int]? {
        guard let options = options else { fatalError("Must have options") }
        switch options {
        case .bool: fatalError("bool not supported")
        case .openString: fatalError("open String not supported")
        case .openInt: fatalError("open Int not supported")
        case .integer(let values): return values
        case .string(_): return nil
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateUIForSelectedIndex()
    }
    
    private func setupTableView() {
        tableView.register(TweakSelectCell.self)
        tableView.tableFooterView = UIView()
    }
    
}

extension TweakSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfValues
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweakSelectCell = tableView.dequeueCell()
        
        if let stringValues = stringValues {
            cell.tweakValueLabel.text = stringValues[indexPath.row]
        } else if let intValues = intValues {
            cell.tweakValueLabel.text = String(intValues[indexPath.row])
        }
        return cell
    }
    
}


extension TweakSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if let selectedIndex = selectedIndex {
            updateValue(for: selectedIndex)
        }
        delegate?.didChangeValue(tweak: tweak, newValue: tweak.value, tweakSelectViewController: self)
        navigationController?.popViewController(animated: true)
    }
    
    private func updateValue(for selectedIndex: Int) {
        if let intValues = intValues {
            tweak?.value = intValues[selectedIndex]
        } else if let stringValues = stringValues {
            tweak?.value = stringValues[selectedIndex]
        }
    }
    
}

