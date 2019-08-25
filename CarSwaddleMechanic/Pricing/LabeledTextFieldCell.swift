//
//  LabeledTextFieldCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 8/22/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI

final class LabeledTextFieldCell: UITableViewCell, NibRegisterable {
    
    var textChanged: (_ text: String?) -> Void = { _ in }
    public var didBeginEditing: () -> Void = {  }
    public var didTapReturn: (_ textField: UITextField) -> Void = { _ in }
    
    @IBOutlet public var labeledTextField: LabeledTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labeledTextField.textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        labeledTextField.textField.delegate = self
        selectionStyle = .none
    }
    
    
    @objc private func didChangeText(_ textField: UITextField) {
        textChanged(textField.text)
    }
    
}

extension LabeledTextFieldCell: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        didBeginEditing()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapReturn(textField)
        return true
    }
    
}
