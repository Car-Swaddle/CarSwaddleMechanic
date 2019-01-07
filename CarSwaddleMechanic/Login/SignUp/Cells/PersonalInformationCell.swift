//
//  PersonalInformationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/24/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class PersonalInformationCell: UITableViewCell, NibRegisterable {

    public var didChangeText: (_ newText: String?) -> Void = { _ in }
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        textField.addTarget(self, action: #selector(PersonalInformationCell.textWasChanged(textField:)), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc private func textWasChanged(textField: UITextField) {
        didChangeText(textField.text)
    }
    
}
