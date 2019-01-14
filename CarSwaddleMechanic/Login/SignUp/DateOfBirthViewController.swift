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
    
    weak var navigationDelegate: NavigationDelegate?
    
    private let mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date().dateByAdding(years: -18) ?? Date()
        
        datePicker.maximumDate = Date().dateByAdding(years: -18)
        datePicker.date = date
        dateLabel.text = dateOfBirthFormatter.string(from: date)
    }

    @IBAction private func dateDidChange(_ datePicker: UIDatePicker) {
        dateLabel.text = dateOfBirthFormatter.string(from: datePicker.date)
    }
    
    @IBAction private func didTapSave() {
        let previousButton = navigationItem.rightBarButtonItem
        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
        navigationItem.rightBarButtonItem = spinButton
        let newDate = datePicker.date
        
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.update(dateOfBirth: newDate, in: privateContext) { mechanicID, error in
                DispatchQueue.main.async {
                    if let navigationDelegate = self?.navigationDelegate, let self = self {
                        navigationDelegate.didFinish(navigationDelegatingViewController: self)
                    } else {
                        self?.navigationItem.rightBarButtonItem = previousButton
                        if error == nil {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
}
