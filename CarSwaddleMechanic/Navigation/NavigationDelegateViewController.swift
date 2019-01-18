//
//  NavigationDelegateViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Authentication

public typealias NavigationDelegatingViewController = (UIViewController & NavigationDelegating)

public protocol NavigationDelegate: AnyObject {
    func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController)
}

public protocol NavigationDelegating: AnyObject {
    var navigationDelegate: NavigationDelegate? { get set }
}

public final class NavigationDelegateViewController: UINavigationController, NavigationDelegate {
    
    private var navigationDelegatingViewControllers: [NavigationDelegatingViewController]
    
    private func createLogoutButton() -> UIBarButtonItem {
        let title = NSLocalizedString("Logout", comment: "logout button")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(NavigationDelegateViewController.viewControllerDidSelectLogout))
        return button
    }

    @objc private func viewControllerDidSelectLogout() {
        DispatchQueue.main.async {
            finishTasksAndInvalidate {
                try? store.destroyAllData()
                try? profileImageStore.destroy()
                AuthController().removeToken()
                DispatchQueue.main.async {
                    navigator.navigateToLoggedOutViewController()
                }
            }
        }
    }
    
    init(navigationDelegatingViewControllers: [NavigationDelegatingViewController]) {
        self.navigationDelegatingViewControllers = navigationDelegatingViewControllers
        super.init(nibName: nil, bundle: nil)
        for navigationDelegatingViewController in navigationDelegatingViewControllers {
            navigationDelegatingViewController.navigationDelegate = self
            navigationDelegatingViewController.navigationItem.leftBarButtonItem = createLogoutButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        if let viewController = navigationDelegatingViewControllers.first {
            viewControllers.append(viewController)
        } else {
            assert(false, "Should have a VC")
        }
    }
    
    
    public func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController) {
        if let next = self.viewController(after: navigationDelegatingViewController) {
            show(next, sender: self)
        } else {
            navigator.navigateToLoggedInViewController()
        }
    }
    
    private func viewController(after navigationDelegatingViewController: NavigationDelegatingViewController) -> NavigationDelegatingViewController? {
        let currentIndex = navigationDelegatingViewControllers.firstIndex { n -> Bool in
            return navigationDelegatingViewController == n
        }
        guard let index = currentIndex,
            let next = navigationDelegatingViewControllers.safeObject(at: index + 1) else { return nil }
        return next
    }
    
}
