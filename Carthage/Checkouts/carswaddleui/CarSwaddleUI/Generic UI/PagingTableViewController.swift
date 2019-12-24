//
//  PagingTableViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 9/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


open class PagingTableViewController: TableViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        requestDataIfNeeded()
    }
    
    /// The offset at which to trigger the request of more data
    open var pageOffset: Int = 3
    /// The number of items to fetch for the next page request
    open var pageCount: Int = 30
    
    open var shouldPage: Bool = true
    
    /// The current number of items locally
    public private(set) var currentPageOffset: Int = 0
    
    private var isRequestingData: Bool = false
    private var didReachEndOfPage: Bool = false
    
    open override func didPullToRefresh() {
        currentPageOffset = 0
        requestDataIfNeeded { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        if isIndexPathPastItemOffset(indexPath: indexPath) && shouldPage {
            requestDataIfNeeded()
        }
    }
    
    private func isIndexPathPastItemOffset(indexPath: IndexPath) -> Bool {
        return indexPath.row >= (currentPageOffset - pageOffset)
    }
    
    public func requestDataIfNeeded(completion: @escaping () -> Void = {}) {
        if currentPageOffset == 0 {
            didReachEndOfPage = false
        }
        guard shouldRequestData else {
            completion()
            return
        }
        let requestedItemCount = pageCount
        self.isRequestingData = true
        requestData(offset: currentPageOffset, count: requestedItemCount) { [weak self] numberOfObjectsFetched in
            guard let self = self else { return }
            defer {
                self.isRequestingData = false
                completion()
            }
            guard let numberOfObjectsFetched = numberOfObjectsFetched else { return }
            if numberOfObjectsFetched <= requestedItemCount {
                self.didReachEndOfPage = true
            }
            self.currentPageOffset += numberOfObjectsFetched
        }
    }
    
    private var shouldRequestData: Bool {
        return !didReachEndOfPage && !isRequestingData
    }
    
    open func requestData(offset: Int, count: Int, completion: @escaping (_ numberOfObjectsFetched: Int?) -> Void) {
        assert(false, "Should implement \(#function) to fetch data")
        completion(nil)
    }
    
}


