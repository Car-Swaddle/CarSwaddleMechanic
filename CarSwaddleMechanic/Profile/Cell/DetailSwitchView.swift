//
//  DetailSwitchView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/29/20.
//  Copyright © 2020 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class DetailSwitchView: UIView, NibInstantiating {
    
    var switchDidChangeValue: (_ newValue: Bool) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = .title
        detailLabel.font = .detail
    }
    
    var titleText: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var detailText: String? {
        get { return detailLabel.text }
        set { detailLabel.text = newValue }
    }
    
    var switchIsOn: Bool {
        get { return valueSwitch.isOn }
        set { valueSwitch.isOn = newValue }
    }
    
    @IBOutlet weak var valueSwitch: UISwitch!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    @IBAction private func switchDidChange(_ activeSwitch: UISwitch) {
        switchDidChangeValue(activeSwitch.isOn)
    }
    
}


final class DetailSwitchViewWrapper: UIView {
    
    let view: DetailSwitchView = DetailSwitchView.viewFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        addSubview(view)
        view.pinFrameToSuperViewBounds()
    }
    
}
