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
    
    enum Tab: Int, CaseIterable {
        case schedule
        case earnings
        case profile
        
        fileprivate var name: String {
            switch self {
            case .schedule:
                return "Schedule"
            case .profile:
                return "Profile"
            case .earnings:
                return "Earnings"
            }
        }
        
    }
    
}

let navigator = Navigator()

final class Navigator: NSObject, TweakViewControllerDelegate {
    
    public override init() {
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    public func setupWindow() {
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = navigator.initialViewController()
        appDelegate.window?.makeKeyAndVisible()
        
        #if DEBUG
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(Navigator.didTripleTap))
        tripleTap.numberOfTapsRequired = 3
        appDelegate.window?.addGestureRecognizer(tripleTap)
        #endif
        
        if AuthController().token != nil {
            pushNotificationController.requestPermission()
            showRequiredScreensIfNeeded()
        }
    }
    
    #if DEBUG
    
    @objc private func didTripleTap() {
        let allTweaks = Tweak.all
        let tweakViewController = TweakViewController.create(with: allTweaks, delegate: self)
        let navigationController = tweakViewController.inNavigationController()
        
        appDelegate.window?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func didDismiss(requiresAppReset: Bool, tweakViewController: TweakViewController) {
        if requiresAppReset {
            logout.logout()
        }
    }
    
    #endif
    
    private func showRequiredScreensIfNeeded() {
//        guard let userID = User.currentUserID else { return }
//        guard let mechanic = Mechanic.fetch(with: userID, in: store.mainContext) else { return }
//            mechanic.scheduleTimeSpans.count == 0 else { return
//        let availabilityViewController = AvailabilityViewController.create(shouldCreateDefaultTimeSpans: true)
        
        let viewControllers = requiredViewControllers()
        guard viewControllers.count > 0 else { return }
        
        let navigationDelegateViewController = NavigationDelegateViewController(navigationDelegatingViewControllers: viewControllers)
        appDelegate.window?.rootViewController?.present(navigationDelegateViewController, animated: true, completion: nil)
    }
    
    private func requiredViewControllers() -> [NavigationDelegatingViewController] {
        
        var viewControllers: [NavigationDelegatingViewController] = []
        
        let currentMechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext)
        
        if currentMechanic?.user?.firstName == nil || currentMechanic?.user?.lastName == nil {
            let name = NameViewController.viewControllerFromStoryboard()
            viewControllers.append(name)
        }
        
        if currentMechanic?.dateOfBirth == nil {
            let dateOfBirth = DateOfBirthViewController.create(with: currentMechanic?.dateOfBirth)
            viewControllers.append(dateOfBirth)
        }
        
        return viewControllers
    }
    
    
//    private func currentRequiredViewController() -> UIViewController? {
//        // TODO: If Mechanic doesn't have personalInformation
//        return nil
////        return BankAccountViewController.viewControllerFromStoryboard()
//        if Mechanic.currentLoggedInMechanic(in: store.mainContext)?.address == nil {
//            return BankAccountViewController.viewControllerFromStoryboard()
////            return PersonalInformationViewController.viewControllerFromStoryboard()
//        } else {
//            return nil
//        }
//    }
    
    
    
    
    
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
            pushNotificationController.requestPermission()
            self.showRequiredScreensIfNeeded()
        }
    }
    
    public func navigateToLoggedOutViewController(animated: Bool = true) {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let signUp = SignUpViewController.viewControllerFromStoryboard()
        let newViewController = signUp.inNavigationController()
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = newViewController
            }) { [weak self] completed in
                self?.removeUI()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        } else {
            window.rootViewController = newViewController
            removeUI()
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private var _tabBarController: UITabBarController?
    private var tabBarController: UITabBarController {
        if let _tabBarController = _tabBarController {
            return _tabBarController
        }
        var viewControllers: [UIViewController] = []
        
        for tab in Tab.allCases {
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
    }
    
    private var _servicesViewController: ScheduleViewController?
    private var servicesViewController: ScheduleViewController {
        if let _servicesViewController = _servicesViewController {
            return _servicesViewController
        }
        
        let servicesViewController = ScheduleViewController.scheduleViewController(for: Date())
        let title = NSLocalizedString("Schedule", comment: "Title of tab item.")
        servicesViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _servicesViewController = servicesViewController
        return servicesViewController
    }
    
    private var _profileViewController: ProfileViewController?
    private var profileViewController: ProfileViewController {
        if let _profileViewController = _profileViewController {
            return _profileViewController
        }
        let profileViewController = ProfileViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Profile", comment: "Title of tab item.")
        profileViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _profileViewController = profileViewController
        return profileViewController
    }
    
    private var _earningsViewController: EarningsViewController?
    private var earningsViewController: EarningsViewController {
        if let _earningsViewController = _earningsViewController {
            return _earningsViewController
        }
        let earningsViewController = EarningsViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Earnings", comment: "Title of tab item.")
        earningsViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _earningsViewController = earningsViewController
        return earningsViewController
    }
    
    private func removeUI() {
        _tabBarController = nil
        _servicesViewController = nil
        _profileViewController = nil
        _earningsViewController = nil
    }
    
    private func viewController(for tab: Tab) -> UIViewController {
        switch tab {
        case .schedule:
            return servicesViewController
        case .profile:
            return profileViewController
        case .earnings:
            return earningsViewController
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
        } else if root == self.earningsViewController {
            return .earnings
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
