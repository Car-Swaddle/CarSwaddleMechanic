//
//  DeletingTextField.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 2/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

@objc public protocol DeletingTextFieldDelegate: AnyObject {
    func didDeleteBackward(_ textField: DeletingTextField)
}

public final class DeletingTextField: UnderlineTextField {
    
    @IBOutlet public weak var deleteDelegate: DeletingTextFieldDelegate?
    
    public override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.didDeleteBackward(self)
    }
    
}
