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
import CarSwaddleStore
import CarSwaddleData

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
    
    private var autoServiceNetwork: AutoServiceNetwork = AutoServiceNetwork(serviceRequest: serviceRequest)
    
    private var stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
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
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 20) as Any]
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().barTintColor = .veryLightGray
        UINavigationBar.appearance().isTranslucent = false
        UITextField.appearance().tintColor = .secondary
        
        let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .semiBold, size: 10) as Any,
            .foregroundColor: UIColor.secondary
        ]
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
        
        let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .regular, size: 10) as Any,
            .foregroundColor: UIColor.lightGray
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalTabBarAttributes, for: .normal)
        UITabBar.appearance().tintColor = .secondary
        
        UISwitch.appearance().tintColor = .secondary
        UISwitch.appearance().onTintColor = .secondary
        UINavigationBar.appearance().tintColor = .secondary
        
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 17) as Any]
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused, .reserved] {
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: state)
        }
        
        UITableViewCell.appearance().textLabel?.font = UIFont.appFont(type: .regular, size: 14)
        
        let actionButton = ActionButton.appearance()
        actionButton.defaultTitleFont = UIFont.appFont(type: .semiBold, size: 20)
        actionButton.defaultBackgroundColor = .secondary
        
        CarSwaddleUI.ContentInsetAdjuster.defaultBottomOffset = navigator.tabBarController.tabBar.bounds.height
        
        CustomAlertAction.cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
        
        defaultLabeledTextFieldTextFieldFont = UIFont.appFont(type: .regular, size: 15)
        defaultLabeledTextFieldLabelNotExistsFont = UIFont.appFont(type: .semiBold, size: 15)
        defaultLabeledTextFieldLabelFont = UIFont.appFont(type: .regular, size: 15)
        
//        let labeledTextFieldAppearance = LabeledTextField.appearance()
//        labeledTextFieldAppearance.underlineColor = .secondary
        
        ContentInsetAdjuster.defaultBottomOffset = tabBarController.tabBar.bounds.height
        
        let labeledTextFieldAppearance = LabeledTextField.appearance()
        labeledTextFieldAppearance.underlineColor = .action
        labeledTextFieldAppearance.textFieldBackgroundColor = .secondaryBackground
        labeledTextFieldAppearance.labelTextColor = .detailTextColor
        labeledTextFieldAppearance.textFieldTextColor = .text
        
        CircleButton.appearance().buttonColor = .text
        
        if #available(iOS 13, *) {
            let style = UINavigationBarAppearance()
            style.buttonAppearance.normal.titleTextAttributes = barButtonTextAttributes
            style.doneButtonAppearance.normal.titleTextAttributes = [.font: UIFont.action as Any, .foregroundColor: UIColor.action as Any]
            
            style.titleTextAttributes = [.font: UIFont.extralarge]
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.standardAppearance = style
            navigationBar.scrollEdgeAppearance = style
            navigationBar.compactAppearance = style
        }
        
        let alertAppearance = CustomAlertContentView.appearance()
        alertAppearance.backgroundColor = .background
        alertAppearance.titleTextColor = .text
        alertAppearance.messageTextColor = .secondaryText
        
        alertAppearance.normalButtonColor = .secondaryBackground
        alertAppearance.normalButtonTitleColor = .text
        alertAppearance.buttonBorderColor = .clear
        
        alertAppearance.preferredButtonColor = .action
        alertAppearance.preferredButtonTitleColor = .inverseText
        
        //        alertAppearance.textFieldUnderlineColor = .purple
        
        alertAppearance.buttonTitleFont = .title
        
        alertAppearance.titleFont = .extralarge
        alertAppearance.buttonTitleFont = .title
        alertAppearance.messageFont = .title
        
        alertAppearance.textFieldFont = .title
        
        alertAppearance.switchLabelFont = .detail
        alertAppearance.switchLabelTextColor = .text
        
        alertAppearance.textFieldBorderColor = .secondaryContent
        
        CustomAlertController.alertBackgroundColor = .background
        CustomAlertController.transparentBackgroundColor = UIColor.neutral3.withAlphaComponent(0.5)
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
        navigationDelegateViewController.modalPresentationStyle = .fullScreen
        presentAtRoot(viewController: navigationDelegateViewController)
    }
    
    private func presentAtRoot(viewController: UIViewController) {
        appDelegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
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
    
    public var isLoggedIn: Bool {
        return AuthController().token != nil
    }
    
    func showEnterNewPasswordScreen(resetToken: String) {
        let enterPassword = EnterNewPasswordViewController.create(resetToken: resetToken)
        presentAtRoot(viewController: enterPassword.inNavigationController())
    }
    
//    public func showRatingAlertFor(autoServiceID: String) {
//        guard isLoggedIn else { return }
//        let alert = ratingController.createRatingAlert(forAutoServiceID: autoServiceID)
//        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
//    }
    
    public func showAutoService(autoServiceID: String) {
        guard isLoggedIn else { return }
        store.privateContext { [weak self] privateContext in
            self?.autoServiceNetwork.getAutoServiceDetails(autoServiceID: autoServiceID, in: privateContext) { autoServiceObjectID, error in
                store.mainContext { mainContext in
                    guard let self = self else { return }
                    guard let autoService = AutoService.fetch(with: autoServiceID, in: store.mainContext) else { return }
                    let viewController = self.viewController(for: .schedule)
                    UIViewController.dismissToViewController(viewController) { success in
                        self.tabBarController.selectedIndex = Tab.schedule.rawValue
                        if let navigationController = viewController.navigationController {
                            let viewController = AutoServiceDetailsViewController.create(autoService: autoService)
                            navigationController.show(viewController, sender: self)
                        }
                    }
                }
            }
        }
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
            navigationController.tabBarItem.badgeColor = .red5
            viewControllers.append(navigationController)
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
//        tabController.tabBar.tintColor = .black
//        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9)]
//        tabController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        tabController.view.backgroundColor = .white
        
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.updateCurrentUserVerification(in: privateContext) { objectID, error in
                DispatchQueue.main.async {
                    let tabBarItem = self?.viewController(for: .profile).tabBarItem
                    let mechanic = User.currentUser(context: store.mainContext)?.mechanic
                    tabBarItem?.badgeValue = mechanic?.numberOfRequiredItems?.stringValue
                }
            }
        }
        
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
    
    @objc public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        guard let tab = self.tab(from: viewController) else { return }
//        trackEvent(with: Navigator.didChangeTabEvent, attributes: ["Screen": tab.name])
    }
    
    @objc public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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


extension UINavigationController {
    
    public func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popToViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
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



public extension Mechanic {
    
    public var numberOfRequiredItems: Int? {
        var count = verification?.currentlyDue.count ?? 0

        if user?.isEmailVerified == false {
            count += 1
        }
        
        return count == 0 ? nil : count
    }
    
    
}
