//
//  SignUpViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import SafariServices


private let stripeAgreementURLString = "https://stripe.com/us/connect-account/legal"
private let carSwaddleAgreementURLString = "https://carswaddle.net/terms-of-use/"
private let carSwaddlePrivacyPolicyURLString = "https://carswaddle.net/privacy-policy/"

private let unableToLoginErrorTitle = NSLocalizedString("Car Swaddle wasn't able to log you in", comment: "Error message")
private let unableToLoginErrorMessage = NSLocalizedString("Your email or password was incorrect. Please verify your email and password and try again.\n\nDo you already have an account? Tap `Go to login` to login to your account.", comment: "Error message")

final class SignUpViewController: UIViewController, StoryboardInstantiating {
    
    public static let stripeAgreementURL: URL! = URL(string: stripeAgreementURLString)!
    public static let carSwaddleAgreementURL: URL! = URL(string: carSwaddleAgreementURLString)!
    public static let carSwaddlePrivacyURL: URL! = URL(string: carSwaddlePrivacyPolicyURLString)!
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var agreementTextView: UITextView!
    
    @IBOutlet private weak var agreementTextViewHeightConstraint: NSLayoutConstraint!
    
    private var auth = Auth(serviceRequest: serviceRequest)
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.didTapScreen))
        view.addGestureRecognizer(tap)
        
        emailTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.didChangeTextField(_:)), for: .editingChanged)
        
        spinner.isHiddenInStackView = true
        updateSignUpEnabledness()
        
        let tintColor: UIColor = .text2
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: tintColor, .font: UIFont.appFont(type: .semiBold, size: 15) as Any]
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "placeholder text"), attributes: placeholderAttributes)
        emailTextField.textColor = tintColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: "placeholder text"), attributes: placeholderAttributes)
        passwordTextField.textColor = tintColor
        
        signUpButton.setTitleColor(tintColor, for: .normal)
        
        emailTextField.addHairlineView(toSide: .bottom, color: .text)
        passwordTextField.addHairlineView(toSide: .bottom, color: .text)
        
        setupAgreementTextView()
        
        backgroundImageView.image = backgroundImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupAgreementTextView() {
        let tintColor: UIColor = .text2
        
        let termsOfUseText = "Car Swaddle Terms of Use Agreement"
        let privacyPolicyText = "Car Swaddle Privacy Policy"
        let stripeText = "Stripe Connected Account Agreement"
        
        let text = "By registering your account, you agree to the \(termsOfUseText), the \(privacyPolicyText) and the \(stripeText)."
        
        let carSwaddleAgreementRange = (text as NSString).range(of: termsOfUseText)
        let privacyPolicyRange = (text as NSString).range(of: privacyPolicyText)
        let connectAgreementRange = (text as NSString).range(of: stripeText)
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: tintColor, .font: UIFont.appFont(type: .regular, size: 13) as Any])
        
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.stripeAgreementURL), range: connectAgreementRange)
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.carSwaddleAgreementURL), range: carSwaddleAgreementRange)
        attributedText.addAttributes(linkAttributes(with: SignUpViewController.carSwaddlePrivacyURL), range: privacyPolicyRange)
        
        let textViewLinkAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.text2,
            .underlineColor: UIColor.text2,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.appFont(type: .regular, size: 13) as Any
        ]
        
        agreementTextView.textAlignment = .center
        agreementTextView.linkTextAttributes = textViewLinkAttributes
        agreementTextView.isSelectable = true
        
        agreementTextView.attributedText = attributedText.copy() as? NSAttributedString
        agreementTextView.delegate = self
        
        agreementTextViewHeightConstraint.constant = agreementTextView.contentSize.height
    }
    
    private func linkAttributes(with url: URL) -> [NSAttributedString.Key: Any] {
        let attributes: [NSAttributedString.Key: Any] = [
            .link: url
        ]
        return attributes
    }
    
    @objc private func didChangeTextField(_ textField: UITextField) {
        updateSignUpEnabledness()
    }
    
    private func updateSignUpEnabledness() {
        signUpButton.isEnabled = signUpIsAllowed
    }
    
    private var signUpIsAllowed: Bool {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return false
        }
        return email.isValidEmail && password.isValidPassword
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    override var childForStatusBarStyle: UIViewController? {
//        return self
//    }
    
    @objc private func didTapScreen() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction private func didTapSignUp() {
        signUpIfPossible()
    }
    
    private func signUpIfPossible() {
        guard signUpIsAllowed,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                updateSignUpEnabledness()
                return
        }
        
        spinner.isHiddenInStackView = false
        spinner.startAnimating()
        
        signUpButton.isHiddenInStackView = true
        
        store.privateContext { [weak self] context in
            self?.auth.mechanicSignUp(email: email, password: password, context: context) { error in
                guard error == nil && self?.auth.isLoggedIn == true else {
                    DispatchQueue.main.async {
                        self?.spinner.isHiddenInStackView = true
                        self?.spinner.stopAnimating()
                        self?.signUpButton.isHiddenInStackView = false
                        
                        self?.showError(message: unableToLoginErrorMessage, title: unableToLoginErrorTitle)
                    }
                    return
                }
                DispatchQueue.main.async {
                    navigator.navigateToLoggedInViewController()
                }
            }
        }
    }
    
    @IBAction func didTapLogin() {
        let login = LoginViewController.viewControllerFromStoryboard()
        navigationController?.show(login, sender: self)
    }
    
    
    private var safariConfiguration: SFSafariViewController.Configuration {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        return configuration
    }
    
    @IBAction func didTapCarSwaddleAgreement() {
        showSafari(with: SignUpViewController.carSwaddleAgreementURL)
    }
    
    @IBAction func didTapStripeAgreement() {
        showSafari(with: SignUpViewController.stripeAgreementURL)
    }
    
    private func showSafari(with url: URL) {
        let stripeSafariViewController = SFSafariViewController(url: url, configuration: safariConfiguration)
        present(stripeSafariViewController, animated: true, completion: nil)
    }
    
    private func showError(message: String, title: String) {
        let contentView = CustomAlertContentView.view(withTitle: title, message: message)
        contentView.addOkayAction()
        let alert = CustomAlertController.viewController(contentView: contentView)
        present(alert, animated: true, completion: nil)
    }
    
    private var backgroundImage: UIImage? {
        let top = GradientPoint(location: 1.0, color: UIColor.background.color(adjustedBy255Points: 15))
        let middle = GradientPoint(location: 0.6, color: UIColor.background.color(adjustedBy255Points: 0))
        let bottom = GradientPoint(location: 0.0, color: UIColor.background.color(adjustedBy255Points: -15))
        return UIImage(size: view.bounds.size, gradientPoints: [top, middle, bottom])
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signUpIfPossible()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSignUpEnabledness()
        return true
    }
    
}

extension SignUpViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if SignUpViewController.stripeAgreementURL == URL || SignUpViewController.carSwaddleAgreementURL == URL || SignUpViewController.carSwaddlePrivacyURL == URL {
            showSafari(with: URL)
        }
        
        return false
    }
    
}


public extension String {
    
    private static let validateEmailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", String.validateEmailRegex)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        return self.count > 3
    }
    
}
