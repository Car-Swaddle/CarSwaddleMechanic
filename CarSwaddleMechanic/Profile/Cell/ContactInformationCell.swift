
//
//  ContactInformationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/7/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Lottie
import Store

final class ContactInformationCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var animationView: LOTAnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateErrorViewHiddenStatus()
        titleLabel.text = NSLocalizedString("Contact Information", comment: "Description of row")
        accessoryType = .disclosureIndicator
        animationView.animationSpeed = 0.7
        animationView.loopAnimation = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateErrorViewHiddenStatus()
        animationView.play()
    }
    
    private func updateErrorViewHiddenStatus() {
        animationView.isHiddenInStackView = !shouldShowErrorView
    }
    
    private var shouldShowErrorView: Bool {
        return User.currentUser(context: store.mainContext)?.isEmailVerified == false
    }
    
}
