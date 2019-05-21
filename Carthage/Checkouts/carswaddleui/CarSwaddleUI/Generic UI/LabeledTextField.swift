//
//  LabeledTextField.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

@IBDesignable
public final class LabeledTextField: UIView {
    
    public static var defaultTextFieldFont: UIFont = UIFont.appFont(type: .system, size: 15)
    public static var defaultLabelNotExistsFont: UIFont = UIFont.appFont(type: .system, size: 15)
    public static var defaultLabelFont: UIFont = UIFont.appFont(type: .system, size: 15)
    
    lazy public var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy public var textFieldContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    lazy public var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var textFieldText: String? {
        didSet {
            textField.text = textFieldText
            updateLabelFontForCurrentText()
        }
    }
    
    @IBInspectable dynamic public var textFieldToLabelGap: CGFloat = 3 {
        didSet {
            textFieldToLabelVerticalConstraint?.constant = textFieldToLabelGap
        }
    }
    
    @IBInspectable dynamic public var underlineColor: UIColor = .black {
        didSet {
            underlineView.backgroundColor = underlineColor
        }
    }
    
    @IBInspectable dynamic public var textFieldBackgroundColor: UIColor = UIColor(white255: 244) {
        didSet {
            textFieldContainerView.backgroundColor = textFieldBackgroundColor
        }
    }
    
    @IBInspectable public var textFieldPlaceholder: String? {
        didSet {
            textField.placeholder = textFieldPlaceholder
        }
    }
    
    @IBInspectable dynamic public var labelTextColor: UIColor = .black {
        didSet {
            label.textColor = labelTextColor
        }
    }
    
    @IBInspectable dynamic public var labelTextExistsFont: UIFont = LabeledTextField.defaultLabelFont {
        didSet {
            updateLabelFontForCurrentText()
        }
    }
    
    @IBInspectable dynamic public var labelTextNotExistsFont: UIFont = LabeledTextField.defaultLabelNotExistsFont {
        didSet {
            updateLabelFontForCurrentText()
        }
    }
    
    @IBInspectable dynamic public var textFieldFont: UIFont = LabeledTextField.defaultTextFieldFont {
        didSet {
            textField.font = textFieldFont
        }
    }
    
    @IBInspectable public var labelText: String? {
        didSet {
            label.text = labelText
        }
    }
    
    private var underlineView: UIView!
    
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        label.text = "Label"
        underlineView.isHidden = false
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private var textFieldToLabelVerticalConstraint: NSLayoutConstraint?
    
    private func setup() {
        addSubview(textFieldContainerView)
        textFieldContainerView.addSubview(textField)
        
        textFieldContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textFieldContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textFieldContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        textField.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: textFieldContainerView.trailingAnchor, constant: -8).isActive = true
        textField.topAnchor.constraint(equalTo: textFieldContainerView.topAnchor, constant: 8).isActive = true
        textField.bottomAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor, constant: -8).isActive = true
        
        addSubview(label)
        
        textFieldToLabelVerticalConstraint = label.topAnchor.constraint(equalTo: textFieldContainerView.bottomAnchor, constant: textFieldToLabelGap)
        textFieldToLabelVerticalConstraint?.isActive = true
        label.leadingAnchor.constraint(equalTo: textFieldContainerView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(greaterThanOrEqualTo: textFieldContainerView.trailingAnchor, constant: 8).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        self.underlineView = textFieldContainerView.addHairlineView(toSide: .bottom, color: underlineColor, size: 2.0, insets: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        underlineView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(LabeledTextField.didBeginEditing), name: UITextField.textDidBeginEditingNotification, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(LabeledTextField.didEndEditing), name: UITextField.textDidEndEditingNotification, object: textField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LabeledTextField.textDidChange), name: UITextField.textDidChangeNotification, object: textField)
        
        textFieldContainerView.layer.cornerRadius = 8
        textFieldContainerView.backgroundColor = UIColor(white255: 244)
        textFieldContainerView.layer.masksToBounds = true
        
        underlineView.backgroundColor = underlineColor
        textFieldContainerView.backgroundColor = textFieldBackgroundColor
        textField.placeholder = textFieldPlaceholder
        textField.backgroundColor = textFieldBackgroundColor
        label.textColor = labelTextColor
        updateLabelFontForCurrentText()
        textField.font = textFieldFont
        
        updateLabelFontForCurrentText()
    }
    
    @objc private func didBeginEditing() {
        underlineView.isHidden = false
        underlineView.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.underlineView.alpha = 1.0
        }
    }
    
    @objc private func didEndEditing() {
        UIView.animate(withDuration: 0.25, animations: {
            self.underlineView.alpha = 0.0
        }) { isFinished in
            self.underlineView.alpha = 1.0
            self.underlineView.isHidden = true
        }
    }
    
    @objc private func textDidChange() {
//        updateLabelFontForCurrentText()
    }
    
    public func updateLabelFontForCurrentText() {
//        if textField.text == nil || textField.text?.isEmpty == true {
//            configureLabelFontForNoText()
//        } else {
            configureLabelFontForExistingText()
//        }
    }
    
    private func configureLabelFontForNoText() {
        UIView.transition(with: label, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.label.font = self.labelTextNotExistsFont
        }) { isFinished in }
    }
    
    private func configureLabelFontForExistingText() {
        UIView.transition(with: label, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.label.font = self.labelTextExistsFont
        }) { isFinished in }
    }
    
}
