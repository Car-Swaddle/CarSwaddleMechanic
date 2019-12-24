//
//  TableViewSchemaViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


public protocol TableViewControllerRow {
    var identifier: String { get }
}

open class TableViewSchemaController: TableViewController {
    
    public init(schema: [Section]) {
        super.init(nibName: nil, bundle: nil)
        
        refreshControl = nil
        self.schema = schema
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public struct Section {
        public let rows: [TableViewControllerRow]
        
        public init(rows: [TableViewControllerRow]) {
            self.rows = rows
        }
    }
    
    public func setSchema(newSchema: [Section], animated: Bool) {
        schema = newSchema
        // TODO: do that animation
    }
    
    open var schema: [Section] = []
    
    final public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schema[section].rows.count
    }
    
    final public override func numberOfSections(in tableView: UITableView) -> Int {
        return schema.count
    }
    
    final override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: self.row(with: indexPath), indexPath: indexPath)
    }
    
    open func cell(for row: TableViewControllerRow, indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclass must override")
    }
    
    private func row(with indexPath: IndexPath) -> TableViewControllerRow {
        return schema[indexPath.section].rows[indexPath.row]
    }
    
}




