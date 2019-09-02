//
//  MechanicPricingViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 8/21/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CoreData
import Store
import CarSwaddleNetworkRequest

private let blankText = NSLocalizedString("--", comment: "Blank")
private let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel button")
private let buttonTitle = NSLocalizedString("Update Prices", comment: "Update them prices")
private let pricingTitle = NSLocalizedString("Pricing", comment: "Title of screen that lets mechanic set their own price")

let dolarFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.maximumFractionDigits = 2
    
    return numberFormatter
}()


final class CurrentMechanicPricingViewController: MechanicPricingViewController {
    
    private var mechanicID: String
    
    init(mechanicID: String) {
        
        self.mechanicID = mechanicID
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestOilChangePricing()
        let cancelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func requestOilChangePricing(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.getOilChangePricingForCurrentMechanic(in: context) { objectID, error in
                DispatchQueue.main.async {
                    defer {
                        completion()
                    }
                    guard let objectID = objectID, let pricing = store.mainContext.object(with: objectID) as? Store.OilChangePricing else { return }
                    self?.oilChangePricing = pricing
                }
            }
        }
    }
    
}


class MechanicPricingViewController: TableViewSchemaButtonViewController {
    
    convenience public init(oilChangePricing: Store.OilChangePricing?) {
        self.init()
        self.oilChangePricing = oilChangePricing
    }
    
    public init() {
        super.init(schema: [TableViewSchemaController.Section(rows: Row.allCases)])
        title = pricingTitle
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var oilChangePricing: Store.OilChangePricing? {
        didSet {
            if let oilChangePricing = oilChangePricing {
                updatePricing = OilChangePricingUpdate(oilChangePricing: oilChangePricing)
            } else {
                updatePricing = nil
            }
            tableView.reloadData()
        }
    }
    
    private var updatePricing: OilChangePricingUpdate?
    
    public var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    enum Row: String, TableViewControllerRow, CaseIterable {
        case conventional, blend, synthetic, highMileage
        var identifier: String { return rawValue }
    }
    
    override var cellTypes: [NibRegisterable.Type] {
        return [LabeledTextFieldCell.self]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        
        adjuster?.showActionButtonAboveKeyboard = true
        adjuster?.positionActionButton()
    }
    
    @objc private func didTapUpload() {
        guard let update = self.updatePricing else { return }
        actionButton.isLoading = true
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.updateOilChangePricingForCurrentMechanic(newOilChangePriceUpdate: update, in: context) { objectID, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.actionButton.isLoading = false
                    if error == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    override func cell(for tableViewRow: TableViewControllerRow) -> UITableViewCell {
        guard let row = tableViewRow as? Row else { fatalError("Should have row here") }
        let mechanicCell: LabeledTextFieldCell = tableView.dequeueCell()
        mechanicCell.labeledTextField.textField.keyboardType = .decimalPad
        mechanicCell.labeledTextField.prefixText = "$" // Do NOT localize until we support other currencies
        
        if let value = self.value(for: row) {
            mechanicCell.labeledTextField.textField.isUserInteractionEnabled = true
            mechanicCell.labeledTextField.textField.text = dolarFormatter.string(from: NSNumber(cgfloat: value))
        } else {
            mechanicCell.labeledTextField.textField.isUserInteractionEnabled = false
            mechanicCell.labeledTextField.textField.text = blankText
        }
        
        mechanicCell.labeledTextField.labelText = self.label(for: row)
        
        mechanicCell.textChanged = { [weak self] text in
            mechanicCell.labeledTextField.textField.text = self?.currencyFormattedText(text: text)
            self?.updateCell(row: row, with: text)
        }
        
        mechanicCell.didTapReturn = { textField in
            textField.resignFirstResponder()
        }
        
        return mechanicCell
    }
    
    private func currencyFormattedText(text: String?) -> String? {
        guard let text = text else { return nil }
        var newText = text
        
        let  firstIndex: String.Index? = newText.firstIndex(of: Character(currencyFormatter.currencyDecimalSeparator!))
        var lastIndex: String.Index? = newText.lastIndex(of: Character(currencyFormatter.currencyDecimalSeparator!))
        
        while firstIndex != lastIndex && firstIndex != nil && lastIndex != nil {
            if let range = newText.range(of: currencyFormatter.currencyDecimalSeparator, options: .backwards, range: nil, locale: nil) {
                newText = newText.replacingCharacters(in: range, with: "")
            }
            lastIndex = newText.lastIndex(of: Character(currencyFormatter.currencyDecimalSeparator!))
        }
        
        if let range = newText.range(of: currencyFormatter.currencyDecimalSeparator, options: .backwards, range: nil, locale: nil) {
            let d = newText.distance(from: range.upperBound, to: newText.endIndex)
            if d > 2 {
                let indexFirstToRemove = newText.index(range.upperBound, offsetBy: 2)
                newText = newText.replacingCharacters(in: indexFirstToRemove..<newText.endIndex, with: "")
            }
        }
        
        return newText
    }
    
    private func updateCell(row: Row, with text: String?) {
        guard let text = text,
            let newDoubleValue = Float(text) else { return }
        let newValue = newDoubleValue.dollarsToCents
        switch row {
        case .conventional:
            updatePricing?.conventional = newValue
        case .blend:
            updatePricing?.blend = newValue
        case .synthetic:
            updatePricing?.synthetic = newValue
        case .highMileage:
            updatePricing?.highMileage = newValue
        }
    }
    
    private func value(for row: Row) -> CGFloat? {
        guard let updatePricing = updatePricing else { return nil }
        switch row {
        case .conventional: return updatePricing.conventional.centsToDollars
        case .blend: return updatePricing.blend.centsToDollars
        case .synthetic: return updatePricing.synthetic.centsToDollars
        case .highMileage: return updatePricing.highMileage.centsToDollars
        }
    }
    
    private func label(for row: Row) -> String {
        switch row {
        case .conventional: return NSLocalizedString("Conventional", comment: "Oil chage type")
        case .blend: return NSLocalizedString("Blend", comment: "Oil chage type")
        case .synthetic: return NSLocalizedString("Synthetic", comment: "Oil chage type")
        case .highMileage: return NSLocalizedString("High Mileage", comment: "Oil chage type")
        }
    }
    
}


extension OilChangePricingUpdate {
    
    init(oilChangePricing: Store.OilChangePricing) {
        self.init(conventional: Int(oilChangePricing.conventional), blend: Int(oilChangePricing.blend), synthetic: Int(oilChangePricing.synthetic), highMileage: Int(oilChangePricing.highMileage))
    }
    
}


public extension Float {
    
    var dollarsToCents: Int {
        return Int(self * 100)
    }
    
}

public extension Int {
    
    var centsToDollars: CGFloat {
        return CGFloat(self) / 100
    }
    
}


public extension NSNumber {
    
    convenience init(cgfloat: CGFloat) {
        self.init(value: Float(cgfloat))
    }
    
}

public extension String {
    
    
    func removingOccurrences<Target>(of target: Target, options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) -> String where Target : StringProtocol {
        return self.replacingOccurrences(of: target, with: "")
    }
    
    func removingOccurrences<Target>(of targets: [Target], options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) -> String where Target : StringProtocol {
        return replacingOccurrences(of: targets, with: "")
    }
    
    
    func removingCurrencySymbols(with numberFormatter: NumberFormatter) -> String {
        let strings: [String] = [numberFormatter.currencySymbol, numberFormatter.currencyGroupingSeparator]
        return self.removingOccurrences(of: strings)
    }
    
    func replacingOccurrences<Target, Replacement>(of targets: [Target], with replacement: Replacement, options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) -> String where Target : StringProtocol, Replacement : StringProtocol {
        var returningString = self
        for target in targets {
            returningString = returningString.replacingOccurrences(of: target, with: replacement)
        }
        return returningString
    }
    
}
