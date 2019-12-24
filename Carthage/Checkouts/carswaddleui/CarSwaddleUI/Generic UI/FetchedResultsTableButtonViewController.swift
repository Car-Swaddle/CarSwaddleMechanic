//
//  FetchedResultsTableButtonViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CoreData

open class FetchedResultsTableButtonViewController<T: NSFetchRequestResult>: FetchedResultsTableViewController<T> {
    
    public var adjuster: ContentInsetAdjuster? {
        didSet {
            adjuster?.positionActionButton()
        }
    }
    
    public lazy var actionButton: ActionButton = {
        let button = ActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(actionButton)
        
        adjuster = ContentInsetAdjuster(tableView: tableView, actionButton: actionButton)
        adjuster?.showActionButtonAboveKeyboard = true
        adjuster?.positionActionButton()
        
        actionButton.addTarget(self, action: #selector(didSelectActionButton), for: .touchUpInside)
    }
    
    @objc open func didSelectActionButton() {
        
    }
    
}
