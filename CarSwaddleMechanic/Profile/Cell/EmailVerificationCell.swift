//
//  EmailVerificationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleNetworkRequest
import Store
import Lottie

final class EmailVerificationCell: UITableViewCell, NibRegisterable {
    
    var hasSentVerificationEmail: Bool = false
    var didSendVerificationEmail: () -> Void = {}
    
    private var userService: UserService = UserService(serviceRequest: serviceRequest)

    @IBOutlet private weak var sendEmailButton: UIButton!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var animationView: LOTAnimationView!
    
    private lazy var currentUser: User? = {
        return User.currentUser(context: store.mainContext)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        updateUI()
        animationView.animationSpeed = 0.7
        animationView.loopAnimation = true
        
        emailLabel.font = UIFont.appFont(type: .regular, size: 17)
        sendEmailButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func updateUI() {
        emailLabel.text = emailLabelText
        sendEmailButton.isHiddenInStackView = !shouldShowSendVerificationButton
        UIView.performWithoutAnimation {
            self.sendEmailButton.setTitle(buttonTitle, for: .normal)
        }
        animationView.isHiddenInStackView = !shouldShowSendVerificationButton
        animationView.play()
    }
    
    private var buttonTitle: String {
        if hasSentVerificationEmail {
            return NSLocalizedString("Sent", comment: "title of button that has already sent an email verification")
        } else {
            return NSLocalizedString("Send email", comment: "title of button that sends a verification email")
        }
    }
    
    private var shouldShowSendVerificationButton: Bool {
        return currentUser?.isEmailVerified == false
    }
    
    private var emailLabelText: String {
        if currentUser?.isEmailVerified == true {
            let formatString = NSLocalizedString("%@ has been verified", comment: "Verification email has been sent to user")
            return String(format: formatString, currentUser?.email ?? "")
        } else {
            let formatString = NSLocalizedString("%@ has not been verified", comment: "Verification email has been sent to user")
            return String(format: formatString, currentUser?.email ?? "")
        }
    }

    @IBAction func didTapSendEmailButton() {
        UIView.performWithoutAnimation {
            self.sendEmailButton.setTitle(NSLocalizedString("Sending", comment: "Text when sending a verification email"), for: .normal)
        }
        
        sendEmailButton.isEnabled = false
        userService.sendEmailVerificationEmail { [weak self] json, error in
            DispatchQueue.main.async {
                self?.hasSentVerificationEmail = true
                self?.didSendVerificationEmail()
                self?.updateUI()
            }
        }
    }
    
}
