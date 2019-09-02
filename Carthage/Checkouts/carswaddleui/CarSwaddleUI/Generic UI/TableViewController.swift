//
//  TableViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


open class TableViewController: UIViewController, UITableViewDataSource {
    
    @IBInspectable
    open var tableViewStyle: UITableView.Style = .plain
    
    @IBInspectable final private(set) public lazy var tableView: UITableView = {
        var tableView = UITableView(frame: self.view.bounds, style: tableViewStyle)
        return tableView
    }()
    
    public var refreshControl: UIRefreshControl? {
        didSet {
            guard viewIfLoaded != nil else { return }
            updateRefreshControl()
        }
    }
    
    @objc open func didPullToRefresh() {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        view.addSubview(tableView)
        tableView.pinFrameToSuperViewBounds()
        
        tableView.dataSource = self
        //        tableView.delegate = self
        view.sendSubviewToBack(tableView)
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TableViewController.didPullToRefresh), for: .valueChanged)
        self.refreshControl = refresh
        
        updateRefreshControl()
    }
    
    open var cellTypes: [NibRegisterable.Type] {
        return []
    }
    
    private func registerCells() {
        cellTypes.forEach {
            tableView.register($0.nib, forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }
    
    private func updateRefreshControl() {
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Tableview Datasource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("subclass must override")
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("subclass must override")
    }
    //
    //    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return nil
    //    }
    //    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //        return nil
    //    }
    //    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    //    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    //    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        return nil
    //    }
    //    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    //        return index
    //    }
    //    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    //    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    //
    //
    //    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        return nil                Q!
    //    }
}


