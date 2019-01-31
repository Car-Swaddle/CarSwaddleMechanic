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

final class PersonalInformationStatusCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateErrorViewHiddenStatus()
        titleLabel.text = NSLocalizedString("Personal Information", comment: "Description of row")
        updateErrorViewCornerRadius()
        accessoryType = .disclosureIndicator
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateErrorViewCornerRadius()
    }
    
    private func updateErrorViewCornerRadius() {
        errorView.layer.cornerRadius = errorView.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateErrorViewHiddenStatus()
    }
    
    private func updateErrorViewHiddenStatus() {
        errorView.isHiddenInStackView = !shouldShowErrorView
    }
    
    private var shouldShowErrorView: Bool {
        let mechanic = Mechanic.currentLoggedInMechanic(in: store.mainContext)
        guard let verification = mechanic?.verification else { return false }
        return verification.fields.count > 0
    }
    
}
