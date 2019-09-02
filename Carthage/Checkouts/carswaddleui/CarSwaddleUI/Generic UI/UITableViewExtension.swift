//
//  UITableViewExtension.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 8/25/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit


public extension UITableView {
    
    func firstVisibleCell<T: UITableViewCell>(of type: T.Type) -> T? {
        let cell = visibleCells.first { cell -> Bool in
            return cell is T
        } as? T
        return cell
    }
    
    func allVisibleCells<T: UITableViewCell>(of type: T.Type) -> [T] {
        let cells = visibleCells.filter { cell -> Bool in
            return cell is T
        } as? [T]
        return cells ?? []
    }
    
}

extension UICollectionView {
    
    public func firstVisibleCell<T>(of type: T.Type) -> T? {
        let cell = visibleCells.first { cell -> Bool in
            return cell is T
        } as? T
        return cell
    }
    
    func allVisibleCells<T: UICollectionViewCell>(of type: T.Type) -> [T] {
        let cells = visibleCells.filter { cell -> Bool in
            return cell is T
        } as? [T]
        return cells ?? []
    }
    
}


public extension UINavigationController {
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
}


public extension UIViewController {
    
    static func dismissToViewController(_ rootViewController: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                if let navigationController = presentedViewController as? UINavigationController {
                    navigationController.popToRootViewController(animated: true) {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            }
        } else if let navigationController = rootViewController.navigationController {
            navigationController.popToRootViewController(animated: true) {
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
}

