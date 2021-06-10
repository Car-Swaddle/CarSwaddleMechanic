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
import CarSwaddleStore
import UIKit

private let codeNumberOfDigits = 5

private let invalidCodeErrorTitle = NSLocalizedString("It looks like that code was invalid", comment: "Error message")
private let invalidCodeErrorMessage = NSLocalizedString("Please enter the code again, or tap the 'Resend verification code' to send another code. If you didn't receive a text message, please tap `Update phone number` to update your phone number.", comment: "Error message")

final class VerifyPhoneNumberViewController: UIViewController, NavigationDelegating, OneTimeCodeViewControllerDelegate {
    
    weak var navigationDelegate: NavigationDelegate?
    
    private var userNetwork: UserNetwork = UserNetwork(serviceRequest: serviceRequest)
    private var userService: UserService = UserService(serviceRequest: serviceRequest)
    
    private let generator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(oneTimeViewController)
        view.addSubview(oneTimeViewController.view)
        oneTimeViewController.view.pinFrameToSuperViewBounds()
        oneTimeViewController.didMove(toParent: self)
        _ = oneTimeViewController.oneTimeCodeEntryView.becomeFirstResponder()
        
        oneTimeViewController.resendCodeButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.resendCodeButton.tintColor = .background
        
        oneTimeViewController.updatePhoneNumberButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.updatePhoneNumberButton.tintColor = .background
        
        oneTimeViewController.verifyPhoneNumberTitleLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        oneTimeViewController.verifyPhoneNumberDescriptionLabel.font = UIFont.appFont(type: .regular, size: 15)
    }
    
    private func shakeEntryView(completion: @escaping () -> Void) {
        oneTimeViewController.oneTimeCodeEntryView.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.oneTimeViewController.oneTimeCodeEntryView.transform = .identity
        }, completion: { isFinished in
            completion()
        })
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
                    DispatchQueue.main.async {
                        self.generator.notificationOccurred(.error)
                        self.shakeEntryView {
                            self.showAlert(message: invalidCodeErrorMessage, title: invalidCodeErrorTitle)
                        }
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let navigationDelegate = self.navigationDelegate {
                        navigationDelegate.didFinish(navigationDelegatingViewController: self)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String, title: String) {
        let contentView = CustomAlertContentView.view(withTitle: title, message: message)
        contentView.addOkayAction()
        let alert = CustomAlertController.viewController(contentView: contentView)
        present(alert, animated: true, completion: nil)
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
    
    func didSelectUpdatePhoneNumberButton(viewController: OneTimeCodeViewController) {
        showUpdatePhoneNumber()
    }
    
    private func showUpdatePhoneNumber() {
        let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
        phoneNumber.navigationDelegate = self
        show(phoneNumber, sender: self)
    }
    
}

extension VerifyPhoneNumberViewController: NavigationDelegate {
    
    func didFinish(navigationDelegatingViewController: NavigationDelegatingViewController) {
        let verify = VerifyPhoneNumberViewController()
        show(verify, sender: self)
    }
    
}
