//
//  ContentInsetAdjuster.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

private let bottomGapConstant: CGFloat = 16

class ContentInsetAdjuster {
    
    init(tableView: UITableView? = nil, actionButton: ActionButton? = nil) {
        self.tableView = tableView
        self.actionButton = actionButton
        
        self.originalContentInset = tableView?.contentInset ?? .zero
        
        setup()
    }
    
    var tableView: UITableView?
    var actionButton: ActionButton?
    
    /// If this is true, you must call `positionActionButton`.
    var showActionButtonAboveKeyboard: Bool = false
    
    var includeTabBarInKeyboardCalculation: Bool = true
    
    private var actionButtonBottomConstraint: NSLayoutConstraint?
    
    func positionActionButton() {
        guard let actionButton = actionButton, let superview = actionButton.superview else {
            assert(false, "Don't have action button")
            return
        }
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = actionButton.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -bottomGapConstant)
        self.actionButtonBottomConstraint = bottomConstraint
        bottomConstraint.isActive = true
        actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateContentInsets()
    }
    
    func updateContentInsets() {
        if actionButton != nil {
            let insets = defaultContentInsets
            tableView?.contentInset = insets
            tableView?.scrollIndicatorInsets.bottom = insets.bottom
        }
    }
    
    private var originalContentInset: UIEdgeInsets = .zero
    
    private var defaultBottomContentInset: CGFloat {
        if let actionButton = actionButton {
            let inset = actionButton.frame.height + bottomGapConstant
            return inset
        } else {
            return 0
        }
    }
    
    private var defaultContentInsets: UIEdgeInsets {
        let previous = originalContentInset
        return UIEdgeInsets(top: previous.top, left: previous.left, bottom: defaultBottomContentInset, right: previous.right)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if UIApplication.shared.applicationState != .active { return }
//        let newYOffset = (tableView?.contentOffset.y ?? 0)
//        let newContentOffset = CGPoint(x: 0, y: max(0, -newYOffset))
        
        let bottomContentInset: CGFloat
        if actionButton != nil {
            bottomContentInset = defaultBottomContentInset
        } else {
            bottomContentInset = 0
        }
        self.actionButton?.superview?.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25) {
            self.tableView?.contentInset.bottom = bottomContentInset
            self.tableView?.scrollIndicatorInsets.bottom = bottomContentInset
//            self.tableView?.contentOffset = newContentOffset
            self.actionButtonBottomConstraint?.constant = -bottomGapConstant
            self.actionButton?.superview?.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardDidChange(notification: Notification) {
        
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if UIApplication.shared.applicationState != .active { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        var keyboardHeight = keyboardFrame.cgRectValue.height
        keyboardHeight = keyboardHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        if includeTabBarInKeyboardCalculation {
            keyboardHeight = keyboardHeight - navigator.tabBarController.tabBar.bounds.height
        }
        
        
        var contentInsetBottom = keyboardHeight
        
        var newYOffset: CGFloat = 0
        if let tableView = tableView {
            newYOffset = keyboardHeight + tableView.contentOffset.y
            let newWindowHeight = tableView.contentSize.height - (tableView.frame.height - (keyboardHeight + tableView.contentInset.bottom))
            newYOffset = min(newYOffset, newWindowHeight)
        }
        
        if let actionButton = actionButton, showActionButtonAboveKeyboard {
            contentInsetBottom = contentInsetBottom + actionButton.frame.height + bottomGapConstant*2
        }
//        let newContentOffset = CGPoint(x: 0, y: max(0, newYOffset))
        
        self.actionButton?.superview?.layoutIfNeeded()
        
        let options = UIView.AnimationOptions(rawValue: animationCurve)
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.tableView?.contentInset.bottom = contentInsetBottom
            self.tableView?.scrollIndicatorInsets.bottom = contentInsetBottom
//            self.tableView?.contentOffset = newContentOffset
            if self.showActionButtonAboveKeyboard {
                self.actionButtonBottomConstraint?.constant = -(keyboardHeight + bottomGapConstant)
            }
            self.actionButton?.superview?.layoutIfNeeded()
        }) { isFinished in
            
        }
    }
    
}
