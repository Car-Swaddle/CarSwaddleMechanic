//
//  DateOfBirthCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/24/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Foundation
import UIKit

let monthDayYearDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    return dateFormatter
}()

private let doneButtonTitle = NSLocalizedString("Done", comment: "Title of button when selecting a date")
private let selectButtonTitle = NSLocalizedString("Select DOB", comment: "Title of button to select a date")

final class DateOfBirthCell: UITableViewCell, NibRegisterable {
    
    public var date: Date = Date().dateByAdding(years: -18) ?? Date() {
        didSet {
            updateDateLabelWithDate()
            didChangeDate(date)
        }
    }

    public var didChangeDate: (_ newDate: Date) -> Void = { _ in }
    
    public var isExpandedDidChange: (_ isExpanded: Bool) -> Void = { _ in }
    
    var isExpanded: Bool = false {
        didSet {
            updateConstraintsForIsExpanded()
            updateButtonTitle()
            isExpandedDidChange(isExpanded)
        }
    }
    
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private var datePickerToViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var containerViewToContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dateLabelContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        datePicker.maximumDate = Date()
        datePicker.date = date
        datePicker.addTarget(self, action: #selector(datePickerDidChange(datePicker:)), for: .valueChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DateOfBirthCell.didTapContainerView))
        dateLabelContentView.addGestureRecognizer(tap)
        
        clipsToBounds = true
        
        updateConstraintsForIsExpanded()
        updateDateLabelWithDate()
        updateButtonTitle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func updateDateLabelWithDate() {
        dateLabel.text = monthDayYearDateFormatter.string(from: date)
    }
    
    
    
    private func updateButtonTitle() {
        doneButton.setTitle(buttonTitleForIsExpanded, for: .normal)
    }
    
    private var buttonTitleForIsExpanded: String {
        return isExpanded ? doneButtonTitle : selectButtonTitle
    }
    
    private func updateConstraintsForIsExpanded() {
        if isExpanded {
            datePickerToViewBottomConstraint.isActive = true
            containerViewToContentViewBottomConstraint.isActive = false
        } else {
            datePickerToViewBottomConstraint.isActive = false
            containerViewToContentViewBottomConstraint.isActive = true
        }
    }
    
    @objc private func datePickerDidChange(datePicker: UIDatePicker) {
        
    }
    
    @objc private func didTapContainerView() {
        isExpanded = true
    }

    @IBAction private func didTapDone() {
        if isExpanded {
            date = datePicker.date
        }
        isExpanded = !isExpanded
    }
    
}


