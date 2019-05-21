//
//  OneTimeCodeEntryView.swift
//  CarSwaddleUI
//
//  Created by Kyle Kendall on 2/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit

@objc public protocol OneTimeEntryViewDelegate: AnyObject {
    func codeDidChange(code: String, view: OneTimeCodeEntryView)
    func configureTextField(textField: DeletingTextField, view: OneTimeCodeEntryView)
}

open class OneTimeCodeEntryView: UIView {
    
    @IBOutlet public weak var delegate: OneTimeEntryViewDelegate?
    
    @IBInspectable public var spacerText: String = "-" {
        didSet { spacerLabels.forEach { $0.text = spacerText } }
    }
    
    @IBInspectable public var indexesPrecedingSpacer: [Int] = [] {
        didSet { updateStackViewWithTextFields() }
    }
    
    @IBInspectable public var spacerFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            for spacerLabel in spacerLabels {
                spacerLabel.font = spacerFont
            }
        }
    }
    
    @IBInspectable public var spacing: CGFloat = 20 {
        didSet { stackView.spacing = spacing }
    }
    
    @IBInspectable public var digits: Int = 4 {
        didSet { updateStackViewWithTextFields() }
    }
    
    @IBInspectable public var textFieldTintColor: UIColor? {
        didSet { textFields.forEach { $0.tintColor = textFieldTintColor  } }
    }
    
    @IBInspectable public var textFieldBackgroundColor: UIColor = .white {
        didSet { textFields.forEach { $0.backgroundColor = textFieldBackgroundColor } }
    }
    
    @IBInspectable public var textFieldCornerRadius: CGFloat = 3 {
        didSet { textFields.forEach { $0.layer.cornerRadius = textFieldCornerRadius } }
    }
    
    @IBInspectable public var textFieldFont: UIFont = UIFont.boldSystemFont(ofSize: 19) {
        didSet { textFields.forEach { $0.font = textFieldFont } }
    }
    
    @IBInspectable public var underlineColor: UIColor = .black {
        didSet { textFields.forEach { $0.underlineColor = underlineColor } }
    }
    
    public var textFieldWidth: CGFloat? {
        didSet { updateTextFieldWidths() }
    }
    
    public var isSecureTextEntry: Bool = false {
        didSet { textFields.forEach { $0.isSecureTextEntry = isSecureTextEntry } }
    }
    
    private var spacerLabels: [UILabel] = []
    
    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        textFields.first?.becomeFirstResponder()
        return result
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        addSubview(stackView)
        stackView.pinFrameToSuperViewBounds()
        updateStackViewWithTextFields()
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var textFields: [DeletingTextField] = []
    
    private func updateStackViewWithTextFields() {
        for textField in textFields {
            guard let superview = textField.superview else { continue }
            stackView.removeArrangedSubview(superview)
            textField.removeFromSuperview()
        }
        
        for spacerLabel in spacerLabels {
            stackView.removeArrangedSubview(spacerLabel)
            spacerLabel.removeFromSuperview()
        }
        
        spacerLabels.removeAll()
        textFields.removeAll()
        
        for index in 0..<digits {
            let textField = self.createTextField()
            let wrapperView = UIView()
            wrapperView.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addSubview(textField)
            textField.pinFrameToSuperViewBounds()
            
            wrapperView.layer.cornerRadius = textFieldCornerRadius
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOffset = CGSize(width: 2, height: 2)
            wrapperView.layer.shadowRadius = 4
            wrapperView.layer.shadowOpacity = 0.2
            
            stackView.addArrangedSubview(wrapperView)
            textFields.append(textField)
            
            if indexesPrecedingSpacer.contains(index) {
                let spacerLabel = UILabel()
                spacerLabel.text = spacerText
                spacerLabel.font = spacerFont
                spacerLabel.textAlignment = .center
                
                stackView.addArrangedSubview(spacerLabel)
                spacerLabels.append(spacerLabel)
            }
        }
        updateTextFieldWidths()
    }
    
    private var textFieldWidthConstraints: [UITextField: NSLayoutConstraint] = [:]
    
    private func updateTextFieldWidths() {
        if let textFieldWidth = textFieldWidth {
            stackView.distribution = .fill
            for textField in textFields {
                if let constraint = textFieldWidthConstraints[textField] {
                    constraint.constant = textFieldWidth
                } else {
//                    guard let superview = textField.superview else { continue }
                    let constraint = textField.widthAnchor.constraint(equalToConstant: textFieldWidth)
                    constraint.isActive = true
                    textFieldWidthConstraints[textField] = constraint
                }
            }
        } else {
            stackView.distribution = .fillEqually
            for key in textFieldWidthConstraints.keys {
                let constraint = textFieldWidthConstraints[key]
                constraint?.isActive = false
                textFieldWidthConstraints[key] = nil
            }
        }
    }
    
    private func createTextField() -> DeletingTextField {
        let textField = DeletingTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textContentType = .oneTimeCode
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .numberPad
        
        textField.textAlignment = .center
        textField.font = textFieldFont
        textField.layer.cornerRadius = textFieldCornerRadius
        textField.backgroundColor = textFieldBackgroundColor
        textField.tintColor = textFieldTintColor
        textField.underlineColor = underlineColor
        textField.layer.masksToBounds = true
        
        textField.adjustsFontSizeToFitWidth = true
        
        textField.deleteDelegate = self
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(OneTimeCodeEntryView.editingDidChange(_:)), for: .editingChanged)
        
        delegate?.configureTextField(textField: textField, view: self)
        
        return textField
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    @objc private func editingDidChange(_ textField: DeletingTextField) {
        let textCount = textField.text?.count ?? 0
        let textIsGreaterThan2 = textCount > 2
        let textCountIs2 = textCount == 2
        
        if textIsGreaterThan2 {
            setText(textField.text ?? "")
        }
        
        if textCountIs2, let last = textField.text?.last {
            textField.text = String(last)
        }
        
        delegate?.codeDidChange(code: code, view: self)
        guard let index = textFields.firstIndex(of: textField),
            index < textFields.count,
            textIsGreaterThan2 == false,
            textFields[index].text?.isEmpty != true,
            index.advanced(by: 1) < textFields.count else { return }
        let nextIndex = index.advanced(by: 1)
        textFields[nextIndex].becomeFirstResponder()
    }
    
    public var code: String {
        var code = ""
        textFields.forEach { textField in
            code += textField.text ?? ""
        }
        return code
    }
    
}

extension OneTimeCodeEntryView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isPasted = string == UIPasteboard.general.string
        if isPasted {
            setText(string)
            delegate?.codeDidChange(code: code, view: self)
            return false
        } else {
            return true
        }
    }
    
    public func setText(_ string: String) {
        textFields.forEach { $0.text = nil }
        var nextTextField: UITextField?
        for (index, c) in string.enumerated() {
            guard index < textFields.count else {
                nextTextField = nil
                break
            }
            let textField = textFields[index]
            textField.text = String(c)
            nextTextField = textField
        }
        if let textField = nextTextField as? DeletingTextField,
            let nextIndex = textFields.firstIndex(of: textField)?.advanced(by: 1),
            nextIndex < textFields.count {
            let t = textFields[nextIndex]
            t.becomeFirstResponder()
        }
    }
    
}

extension OneTimeCodeEntryView: DeletingTextFieldDelegate {
    
    public func didDeleteBackward(_ textField: DeletingTextField) {
        guard let originalIndex = textFields.firstIndex(of: textField),
            originalIndex > 0 else { return }
        let previousIndex = originalIndex.advanced(by: -1)
        textFields[previousIndex].becomeFirstResponder()
    }
    
}



open class UnderlineTextField: UITextField {
    
    @IBInspectable public var underlineColor: UIColor = .black {
        didSet {
            underlineView.backgroundColor = underlineColor
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private var underlineView: UIView!
    
    private func setup() {
        self.underlineView = addHairlineView(toSide: .bottom, color: underlineColor, size: 2.0, insets: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        underlineView.isHidden = true
        borderStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(UnderlineTextField.didBeginEditing), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(UnderlineTextField.didEndEditing), name: UITextField.textDidEndEditingNotification, object: self)
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
    
}
