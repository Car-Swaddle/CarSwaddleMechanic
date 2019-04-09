//
//  VerifyPhoneNumberViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest
import Store

private let codeNumberOfDigits = 5

final class VerifyPhoneNumberViewController: UIViewController, NavigationDelegating, OneTimeCodeViewControllerDelegate {
    
    weak var navigationDelegate: NavigationDelegate?
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var userService: UserService = UserService(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(oneTimeViewController)
        view.addSubview(oneTimeViewController.view)
        oneTimeViewController.view.pinFrameToSuperViewBounds()
        oneTimeViewController.didMove(toParent: self)
        _ = oneTimeViewController.oneTimeCodeEntryView.becomeFirstResponder()
    }
    
    private lazy var oneTimeViewController: OneTimeCodeViewController = {
        let viewController = OneTimeCodeViewController.viewControllerFromStoryboard()
        viewController.delegate = self
        viewController.numberOfDigits = codeNumberOfDigits
        viewController.phoneNumber = User.currentUser(context: store.mainContext)?.phoneNumber ?? ""
        return viewController
    }()
    
    func codeDidChange(code: String, viewController: OneTimeCodeViewController) {
        guard code.count == codeNumberOfDigits else { return }
        oneTimeViewController.view.endEditing(true)
        store.privateContext { [weak self] privateContext in
            self?.userNetwork.verifySMS(withCode: code, in: privateContext) { userObjectID, error in
                guard let self = self else { return }
                guard error == nil else {
                    print(error ?? "")
                    return
                }
                if let navigationDelegate = self.navigationDelegate {
                    navigationDelegate.didFinish(navigationDelegatingViewController: self)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func didSelectResendVerificationCode(viewController: OneTimeCodeViewController) {
        userService.sendSMSVerification { error in
            if error == nil {
                print("no error resending")
            } else {
                print("error resending")
            }
        }
    }
    
}
