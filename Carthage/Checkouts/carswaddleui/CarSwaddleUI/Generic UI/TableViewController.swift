//
//  TableViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


open class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBInspectable
    open var tableViewStyle: UITableView.Style = .plain
    
    @IBInspectable final private(set) public lazy var tableView: UITableView = {
        var tableView = UITableView(frame: self.view.bounds, style: tableViewStyle)
        return tableView
    }()
    
    public var refreshControl: UIRefreshControl? {
        didSet {
            guard viewIfLoaded != nil else { return }
            if let oldValue = oldValue, refreshControl == nil {
                oldValue.removeFromSuperview()
            }
            updateRefreshControl()
        }
    }
    
    @objc open func didPullToRefresh() {
        print("user pulled to refresh, but it was not implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        view.addSubview(tableView)
        tableView.pinFrameToSuperViewBounds()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.sendSubviewToBack(tableView)
        tableView.tableFooterView = UIView()
        
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
    
    open func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { fatalError("subclass must override") }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { fatalError("subclass must override") }
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return nil }
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return false }
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? { return nil }
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int { return index }
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    // MARK: UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)  { }
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)  { }
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
//    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat  { return UITableView.automaticDimension }
//    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 0 }
//    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
//    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return UITableView.automaticDimension }
//    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return 0 }
//    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat { return 0 }
//    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
//    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
//    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return .delete }
//    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return NSLocalizedString("Delete", comment: "Delete ") }
//    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
//    open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
//    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { return nil }
//    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return true }
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) { }
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) { }
    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath { return proposedDestinationIndexPath }
//    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int { return 0 }
//    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool { return false }
//    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool { return true }
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) { }
//    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { return true }
//    open func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool { return true }
    open func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) { }
    open func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? { return nil }
//    open func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool { return true }
    
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    open func scrollViewDidZoom(_ scrollView: UIScrollView) { }
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) { }
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) { }
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) { }
    
}
