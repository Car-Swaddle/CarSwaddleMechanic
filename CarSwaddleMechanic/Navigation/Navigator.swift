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
        
        fileprivate var removeShadowImage: Bool {
            switch self {
            case .schedule:
                return true
            case .profile, .earnings:
                return false
            }
        }
        
    }
    
}

let navigator = Navigator()

final public class Navigator: NSObject {
    
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
        tripleTap.numberOfTouchesRequired = 2
        appDelegate.window?.addGestureRecognizer(tripleTap)
        #endif
        
        setupAppearance()
        
        if AuthController().token != nil {
            pushNotificationController.requestPermission()
            showRequiredScreensIfNeeded()
        }
    }
    
    private func setupAppearance() {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 20)]
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().barTintColor = .veryLightGray
        UINavigationBar.appearance().isTranslucent = false
        UITextField.appearance().tintColor = .secondary
        
        let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .semiBold, size: 10),
            .foregroundColor: UIColor.viewBackgroundColor1
        ]
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
        
        let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .regular, size: 10),
            .foregroundColor: UIColor.lightGray
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalTabBarAttributes, for: .normal)
        UITabBar.appearance().tintColor = .secondary
        
        UISwitch.appearance().tintColor = .secondary
        UISwitch.appearance().onTintColor = .secondary
        UINavigationBar.appearance().tintColor = .viewBackgroundColor1
        
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 17)]
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused, .reserved] {
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: state)
        }
        
        UITableViewCell.appearance().textLabel?.font = UIFont.appFont(type: .regular, size: 14)
        
        let actionButton = ActionButton.appearance()
        actionButton.defaultTitleFont = UIFont.appFont(type: .bold, size: 23)
        actionButton.defaultBackgroundColor = .red
        
        CarSwaddleUI.ContentInsetAdjuster.defaultBottomOffset = navigator.tabBarController.tabBar.bounds.height
    }
    
    #if DEBUG
    
    @objc private func didTripleTap() {
        let allTweaks = Tweak.all
        let tweakViewController = TweakViewController.create(with: allTweaks, delegate: self)
        let navigationController = tweakViewController.inNavigationController()
        
        appDelegate.window?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    public func didDismiss(requiresAppReset: Bool, tweakViewController: TweakViewController) {
        if requiresAppReset {
            logout.logout()
        }
    }
    
    #endif
    
    private func showRequiredScreensIfNeeded() {
        let viewControllers = requiredViewControllers()
        guard viewControllers.count > 0 else { return }
        
        let navigationDelegateViewController = NavigationDelegateViewController(navigationDelegatingViewControllers: viewControllers)
        navigationDelegateViewController.externalDelegate = self
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
        
        if currentMechanic?.user?.phoneNumber == nil {
            let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
            viewControllers.append(phoneNumber)
        }
        
        if currentMechanic?.user?.isPhoneNumberVerified == false {
            let verify = VerifyPhoneNumberViewController()
            viewControllers.append(verify)
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
    
    
    
    
    
    private(set) var appDelegate: AppDelegate
    
    public func initialViewController() -> UIViewController {
        if AuthController().token == nil {
            let signUp = SignUpViewController.viewControllerFromStoryboard()
            let navigationController = signUp.inNavigationController()
            navigationController.navigationBar.barStyle = .black
            navigationController.navigationBar.isHidden = true
//            navigationController.setNeedsStatusBarAppearanceUpdate()
//            navigationController.setNavigationBarHidden(true, animated: false)
//            navigationController.interactivePopGestureRecognizer?.delegate = nil
            return navigationController
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
        let navigationController = signUp.inNavigationController()
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isHidden = true
        navigationController.view.frame = rootViewController.view.frame
        navigationController.view.layoutIfNeeded()
        
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = navigationController
            }) { [weak self] completed in
                self?.removeUI()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        } else {
            window.rootViewController = navigationController
            removeUI()
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private var _tabBarController: UITabBarController?
    var tabBarController: UITabBarController {
        if let _tabBarController = _tabBarController {
            return _tabBarController
        }
        var viewControllers: [UIViewController] = []
        
        for tab in Tab.allCases {
            let viewController = self.viewController(for: tab)
            let navigationController = viewController.inNavigationController()
            if tab.removeShadowImage {
                navigationController.navigationBar.shadowImage = UIImage()
            }
            viewControllers.append(navigationController)
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
//        tabController.tabBar.tintColor = .black
//        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9)]
//        tabController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        tabController.view.backgroundColor = .white
        
        _tabBarController = tabController
        
        return tabController
    }
    
    private var _servicesViewController: ScheduleViewController?
    private var servicesViewController: ScheduleViewController {
        if let _servicesViewController = _servicesViewController {
            return _servicesViewController
        }
        
        let servicesViewController = ScheduleViewController.scheduleViewController(for: Date())
        let title = NSLocalizedString("Calendar", comment: "Title of tab item.")
        let image = #imageLiteral(resourceName: "calendar")
        let selectedImage = #imageLiteral(resourceName: "calendar-filled")
        servicesViewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
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
        let image = #imageLiteral(resourceName: "user")
        let selectedImage = #imageLiteral(resourceName: "user")
        profileViewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
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
        let image = #imageLiteral(resourceName: "us-dollar")
        let selectedImage = #imageLiteral(resourceName: "us-dollar")
        earningsViewController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
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

#if DEBUG

extension Navigator: TweakViewControllerDelegate {  }

#endif


extension Navigator: UITabBarControllerDelegate {
    
    private static let didChangeTabEvent = "Did Change Tab"
    
    @objc func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        guard let tab = self.tab(from: viewController) else { return }
//        trackEvent(with: Navigator.didChangeTabEvent, attributes: ["Screen": tab.name])
    }
    
    @objc func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
}

extension Navigator: HorizontalSlideTransitionDelegate {
    
    public func relativeTransition(_ transition: HorizontalSlideTransition, fromViewController: UIViewController, toViewController: UIViewController) -> HorizontalSlideDirection {
        guard let fromTab = self.tab(from: fromViewController),
            let toTab = self.tab(from: toViewController) else { return .left }
        return fromTab.rawValue < toTab.rawValue ? .left : .right
    }
    
}

extension Navigator: NavigationDelegateViewControllerDelegate {
    
    public func didFinishLastViewController(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
        navigateToLoggedInViewController()
    }
    
    public func didSelectLogout(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.endEditing(true)
        logout.logout()
    }
    
}
