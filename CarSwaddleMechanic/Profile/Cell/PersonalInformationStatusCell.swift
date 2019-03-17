//
//  PersonalInformationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/31/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleData
import Store
import Lottie

final class PersonalInformationStatusCell: UITableViewCell, NibRegisterable {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var animationView: LOTAnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateErrorViewHiddenStatus()
        titleLabel.text = NSLocalizedString("Personal Information", comment: "Description of row")
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
        let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext)
        guard let verification = mechanic?.verification else { return false }
        return verification.currentlyDue.count > 0
    }
    
}
