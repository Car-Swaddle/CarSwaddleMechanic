//
//  DateOfBirthViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/28/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData

public var dateOfBirthFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    return dateFormatter
}()

final class DateOfBirthViewController: UIViewController, StoryboardInstantiating, NavigationDelegating {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var actionButton: ActionButton!
    
    weak var navigationDelegate: NavigationDelegate?
    
    private let mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    static func create(with date: Date?) -> DateOfBirthViewController {
        let viewController = DateOfBirthViewController.viewControllerFromStoryboard()
        viewController.date = date
        return viewController
    }
    
    private var date: Date?
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pickerDate: Date
        if let date = date {
            pickerDate = date
        } else {
            pickerDate = maxDate
        }
        
        datePicker.maximumDate = maxDate
        datePicker.date = pickerDate
        dateLabel.text = dateOfBirthFormatter.string(from: pickerDate)
        
        insetAdjuster.positionActionButton()
    }
    
    private var maxDate: Date {
        return Date().dateByAdding(years: -18) ?? Date()
    }

    @IBAction private func dateDidChange(_ datePicker: UIDatePicker) {
        dateLabel.text = dateOfBirthFormatter.string(from: datePicker.date)
    }
    
    @IBAction private func didTapSave() {
//        let previousButton = navigationItem.rightBarButtonItem
//        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
//        navigationItem.rightBarButtonItem = spinButton
        let newDate = datePicker.date
        
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.update(dateOfBirth: newDate, in: privateContext) { mechanicID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    guard error == nil else {
                        print(error ?? "")
                        return
                    }
                    if let navigationDelegate = self.navigationDelegate {
                        navigationDelegate.didFinish(navigationDelegatingViewController: self)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
}
