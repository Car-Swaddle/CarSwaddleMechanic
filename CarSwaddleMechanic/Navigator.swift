//
//  Navigator.swift
//  CarSwaddle
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Authentication
import CarSwaddleUI
import Store

extension Navigator {
    
    enum Tab: Int {
        case schedule
        case profile
        
        static var all: [Tab] {
            return [.schedule, .profile]
        }
        
        fileprivate var name: String {
            switch self {
            case .schedule:
                return "Schedule"
            case .profile:
                return "Profile"
            }
        }
        
    }
    
}

let navigator = Navigator()

final class Navigator: NSObject {
    
    public override init() {
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    public func setupWindow() {
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = navigator.initialViewController()
        appDelegate.window?.makeKeyAndVisible()
        showRequiredScreensIfNeeded()
    }
    
    private func showRequiredScreensIfNeeded() {
        guard let userID = User.currentUserID else { return }
        guard let mechanic = Mechanic.fetch(with: userID, in: store.mainContext) else { return }
        // TODO: Uncomment this before release
//            mechanic.scheduleTimeSpans.count == 0 else { return
        let availabilityViewController = AvailabilityViewController.viewControllerFromStoryboard()
        appDelegate.window?.rootViewController?.present(availabilityViewController.inNavigationController(), animated: true, completion: nil)
    }
    
    private var appDelegate: AppDelegate
    
    public func initialViewController() -> UIViewController {
        if AuthController().token == nil {
            let signUp = SignUpViewController.viewControllerFromStoryboard()
            return signUp.inNavigationController()
        } else {
            return loggedInViewController
        }
    }
    
    public var loggedInViewController: UIViewController {
        return tabBarController
    }
    
    public func navigateToLoggedInViewController() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let newViewController = loggedInViewController
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { completed in
            self.showRequiredScreensIfNeeded()
        }
    }
    
    lazy private var tabBarController: UITabBarController = {
        var viewControllers: [UIViewController] = []
        
        for tab in Tab.all {
            let viewController = self.viewController(for: tab)
            viewControllers.append(viewController.inNavigationController())
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
//        tabController.tabBar.tintColor = .black
//        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9)]
//        tabController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        tabController.view.backgroundColor = .white
        
        return tabController
    }()
    
    private lazy var servicesViewController: ScheduleViewController = {
        let servicesViewController = ScheduleViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Schedule", comment: "Title of tab item.")
        servicesViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        return servicesViewController
    }()
    
    private lazy var profileViewController: ProfileViewController = {
        let profileViewController = ProfileViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Profile", comment: "Title of tab item.")
        profileViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        return profileViewController
    }()
    
    private func viewController(for tab: Tab) -> UIViewController {
        switch tab {
        case .schedule:
            return servicesViewController
        case .profile:
            return profileViewController
        }
    }
    
    private func tab(from viewController: UIViewController) -> Tab? {
        var root: UIViewController
        if let navigationController = viewController as? UINavigationController,
            let navRoot = navigationController.viewControllers.first {
            root = navRoot
        } else {
            root = loggedInViewController
        }
        
        if root == self.servicesViewController {
            return .schedule
        } else if root == self.profileViewController {
            return .profile
        }
        return nil
    }
    
    lazy private var transition: HorizontalSlideTransition = {
        return HorizontalSlideTransition(delegate: self)
    }()
    
}


extension Navigator: UITabBarControllerDelegate {
    
    private static let didChangeTabEvent = "Did Change Tab"
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("changed tab")
//        guard let tab = self.tab(from: viewController) else { return }
//        trackEvent(with: Navigator.didChangeTabEvent, attributes: ["Screen": tab.name])
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
}

extension Navigator: HorizontalSlideTransitionDelegate {
    
    func relativeTransition(_ transition: HorizontalSlideTransition, fromViewController: UIViewController, toViewController: UIViewController) -> HorizontalSlideDirection {
        guard let fromTab = self.tab(from: fromViewController),
            let toTab = self.tab(from: toViewController) else { return .left }
        return fromTab.rawValue < toTab.rawValue ? .left : .right
    }
    
}
