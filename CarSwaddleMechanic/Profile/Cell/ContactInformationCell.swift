
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
import CarSwaddleStore

final class ContactInformationCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateErrorViewHiddenStatus()
        titleLabel.text = NSLocalizedString("Contact Information", comment: "Description of row")
        accessoryType = .disclosureIndicator
        
        titleLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        animationView.animation = Animation.named("circle-pulse")
        animationView.animationSpeed = 0.7
        animationView.loopMode = .loop
        
        selectionStyle = .none
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
