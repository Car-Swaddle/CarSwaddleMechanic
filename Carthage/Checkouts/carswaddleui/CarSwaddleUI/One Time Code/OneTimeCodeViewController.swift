//
//  OneTimeCodeViewController.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 2/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

public protocol OneTimeCodeViewControllerDelegate: AnyObject {
    func codeDidChange(code: String, viewController: OneTimeCodeViewController)
    func didSelectResendVerificationCode(viewController: OneTimeCodeViewController)
    func didSelectUpdatePhoneNumberButton(viewController: OneTimeCodeViewController)
}

open class OneTimeCodeViewController: UIViewController, StoryboardInstantiating {
    
    public weak var delegate: OneTimeCodeViewControllerDelegate?
    
    public var numberOfDigits: Int = 5 {
        didSet {
            guard viewIfLoaded != nil else { return }
            oneTimeCodeEntryView.digits = numberOfDigits
        }
    }
    
    public var phoneNumber: String = "" {
        didSet {
            guard viewIfLoaded != nil else { return }
            verifyPhoneNumberDescriptionLabel.text = verifyPhoneNumberDescription
        }
    }
    
    @IBOutlet public weak var verifyPhoneNumberTitleLabel: UILabel!
    @IBOutlet public weak var verifyPhoneNumberDescriptionLabel: UILabel!
    @IBOutlet public weak var resendCodeButton: UIButton!
    
    @IBOutlet public weak var updatePhoneNumberButton: UIButton!
    
    @IBOutlet public weak var oneTimeCodeEntryView: OneTimeCodeEntryView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyPhoneNumberDescriptionLabel.text = verifyPhoneNumberDescription
        oneTimeCodeEntryView.digits = numberOfDigits
        oneTimeCodeEntryView.textFieldWidth = 50
    }
    
    @IBAction private func didSelectResendVerificationCode() {
        delegate?.didSelectResendVerificationCode(viewController: self)
    }
    
    @IBAction private func tapUpdatePhoneNumber() {
        delegate?.didSelectUpdatePhoneNumberButton(viewController: self)
    }
    
    private var verifyPhoneNumberDescription: String {
        let formatString = NSLocalizedString("We've sent a verification code to %@. Please enter the code in the space below.", comment: "Verification code description")
        return String(format: formatString, phoneNumber)
    }
    
}

extension OneTimeCodeViewController: OneTimeEntryViewDelegate {
    
    public func configureTextField(textField: DeletingTextField, view: OneTimeCodeEntryView) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowRadius = 3.0
        textField.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    public func codeDidChange(code: String, view: OneTimeCodeEntryView) {
        delegate?.codeDidChange(code: code, viewController: self)
    }
    
}
