//
//  TextFieldCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import UIKit

protocol TextFieldCellDelegate: AnyObject {
    func didChangeText(text: String?, cell: TextFieldCell)
}

final class TextFieldCell: UITableViewCell, NibRegisterable {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldLabel: UILabel!
    
    weak var delegate: TextFieldCellDelegate?
    
    var didChangeText: (_ text: String?) -> Void = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction private func didChangeValue() {
        delegate?.didChangeText(text: textField.text, cell: self)
        didChangeText(textField.text)
    }
}

extension TextFieldCell: UITextFieldDelegate {
    
    
    
}
