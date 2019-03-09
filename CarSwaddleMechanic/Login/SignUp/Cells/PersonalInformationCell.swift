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
    public var didSelectReturn: () -> Void = { }
    
    var textFieldText: String? {
        set {
            labeledTextField.textFieldText = newValue
        }
        get {
            return labeledTextField.textFieldText
        }
    }
    
    var textField: UITextField! {
        return labeledTextField.textField
    }
    
    var label: UILabel! {
        return labeledTextField.label
    }
    
    @IBOutlet private weak var labeledTextField: LabeledTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        labeledTextField.textField.addTarget(self, action: #selector(PersonalInformationCell.textWasChanged(textField:)), for: .editingChanged)
        
        labeledTextField.textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @objc private func textWasChanged(textField: UITextField) {
        didChangeText(textField.text)
    }
    
}

extension PersonalInformationCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didSelectReturn()
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        labeledTextField.updateTextColor()
//        return true
//    }
    
}
