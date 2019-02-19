//
//  AutoServiceCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/10/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

let dayOfWeekMonthDayTimeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM d h:mm a"
    return formatter
}()

let hourMinuteDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter
}()

final class AutoServiceCell: UITableViewCell, NibRegisterable {
    
    var isLastAutoService: Bool = false {
        didSet {
            updateBottomTimelineConstraint()
        }
    }
    
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var vehicleLabel: UILabel!
    @IBOutlet private weak var autoServiceStatusView: UIView!
    @IBOutlet private weak var autoServiceDetailsContentView: UIView!
    @IBOutlet private weak var scheduledDateLabel: UILabel!
    
    private var timelineBuiler: TimelineUIBuilder = TimelineUIBuilder()
    private var timelineHairlineView: UIView?
    
    private var bottomTimelineViewConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let timelineHairlineView = timelineBuiler.addTimelineHairline(to: contentView)
        let (_, _, _, bottomConstraint) = timelineBuiler.addConstraints(toTimelineView: timelineHairlineView, on: contentView)
        self.bottomTimelineViewConstraint = bottomConstraint
        
        autoServiceStatusView.centerXAnchor.constraint(equalTo: timelineHairlineView.centerXAnchor).isActive = true
        self.timelineHairlineView = timelineHairlineView
        
        autoServiceStatusView.layer.cornerRadius = autoServiceStatusView.frame.height / 2
        
        autoServiceDetailsContentView.layer.cornerRadius = 12
        
        scheduledDateLabel.font = UIFont.appFont(type: .regular, size: 17)
        locationLabel.font = UIFont.appFont(type: .regular, size: 17)
        vehicleLabel.font = UIFont.appFont(type: .regular, size: 17)
        userLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        updateBottomTimelineConstraint()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scheduledDateLabel.text = ""
        userLabel.text = ""
        locationLabel.text = ""
        vehicleLabel.text = ""
    }
    
    private func updateBottomTimelineConstraint() {
        if isLastAutoService {
            bottomTimelineViewConstraint?.constant = -bottomToCenterOfStatusView
        } else {
            bottomTimelineViewConstraint?.constant = 0
        }
    }
    
    private var bottomToCenterOfStatusView: CGFloat {
        return frame.height - (autoServiceStatusView.frame.origin.y + (autoServiceStatusView.frame.height/2))
    }
    
    func configure(with autoService: AutoService) {
        if let date = autoService.scheduledDate {
            scheduledDateLabel.text = hourMinuteDateFormatter.string(from: date)
        }
        
        let vehicleFormatString = NSLocalizedString("%@ • %@ • %@", comment: "Vehicle format string: 'vehicle name' • 'license plate number' • 'Oil type'")
        
        let vehicleName = autoService.vehicle?.name ?? ""
        let licensePlateNumber = autoService.vehicle?.licensePlate ?? ""
        let oilType = autoService.firstOilChange?.oilType.localizedString ?? ""
        
        vehicleLabel.text = String(format: vehicleFormatString, vehicleName, licensePlateNumber, oilType)
        userLabel.text = autoService.creator?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
    }
    
}
