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
import MapKit

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

let numberOfMinutesNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 1
    formatter.minimumIntegerDigits = 0
    return formatter
}()

final class AutoServiceCell: UITableViewCell, NibRegisterable {
    
    var isLastAutoService: Bool = false {
        didSet {
            updateBottomTimelineConstraint()
        }
    }
    
    var route: MKRoute? {
        didSet {
            if let route = route {
                let formatString = NSLocalizedString("%@ miles, %@ minutes to next autoservice", comment: "Distance estimate")
                let distanceString = distanceNumberFormatter.string(from: NSNumber(value: route.distance.metersToMiles))!
                let minutesString = numberOfMinutesNumberFormatter.string(from: NSNumber(value: route.expectedTravelTime / 60))!
                self.distanceEstimateLabel.text = String(format: formatString, distanceString, minutesString)
                
                if oldValue == nil {
                    self.distanceEstimateLabel.alpha = 0.0
                    UIView.animate(withDuration: 0.25) {
                        self.distanceEstimateLabel.alpha = 1.0
                    }
                }
            } else {
                distanceEstimateLabel.text = nil
            }
        }
    }
    
    @IBOutlet private weak var userLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var vehicleLabel: UILabel!
    @IBOutlet private weak var autoServiceStatusView: UIView!
    @IBOutlet private weak var autoServiceDetailsContentView: UIView!
    @IBOutlet private weak var scheduledDateLabel: UILabel!
    @IBOutlet private weak var oilTypeLabel: UILabel!
    @IBOutlet private weak var distanceEstimateLabel: UILabel!
    
    private var timelineBuiler: TimelineUIBuilder = TimelineUIBuilder()
    private var timelineHairlineView: UIView?
    
    @IBOutlet private weak var mapView: MKMapView!
    
    private var bottomTimelineViewConstraint: NSLayoutConstraint?
    
    private var autoService: AutoService?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let timelineHairlineView = timelineBuiler.addTimelineHairline(to: contentView)
        let (_, _, _, bottomConstraint) = timelineBuiler.addConstraints(toTimelineView: timelineHairlineView, on: contentView)
        self.bottomTimelineViewConstraint = bottomConstraint
        
        autoServiceStatusView.centerXAnchor.constraint(equalTo: timelineHairlineView.centerXAnchor).isActive = true
        self.timelineHairlineView = timelineHairlineView
        
        autoServiceStatusView.layer.cornerRadius = autoServiceStatusView.frame.height / 2
        
        autoServiceDetailsContentView.layer.cornerRadius = 12
        
        scheduledDateLabel.font = UIFont.appFont(type: .semiBold, size: 17)
        
        locationLabel.font = UIFont.appFont(type: .regular, size: 17)
        vehicleLabel.font = UIFont.appFont(type: .regular, size: 17)
        userLabel.font = UIFont.appFont(type: .regular, size: 17)
        oilTypeLabel.font = UIFont.appFont(type: .regular, size: 17)
//        getDirectionsButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 13)
//        getDirectionsButton.setTitleColor(.gray5, for: .normal)
        
        updateBottomTimelineConstraint()
        
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AutoServiceCell.didSelectGetDirections))
        mapView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBottomTimelineConstraint()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scheduledDateLabel.text = ""
        scheduledDateLabel.text = ""
        userLabel.text = ""
        locationLabel.text = ""
        vehicleLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateSelectionColor(animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        updateSelectionColor(animated: animated)
    }
    
    private func updateSelectionColor(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.autoServiceDetailsContentView.backgroundColor = self.currentContentBackgroundColor
            }
        } else {
            self.autoServiceDetailsContentView.backgroundColor = self.currentContentBackgroundColor
        }
    }
    
    private func updateBottomTimelineConstraint() {
        if isLastAutoService {
            bottomTimelineViewConstraint?.constant = -bottomToCenterOfStatusView
        } else {
            bottomTimelineViewConstraint?.constant = 0
        }
    }
    
    private var currentContentBackgroundColor: UIColor {
        return isSelected || isHighlighted ? selectedBackgroundColor : unselectedBackgroundColor
    }
    
    private let selectedBackgroundColor: UIColor = .gray3
    private let unselectedBackgroundColor: UIColor = UIColor(white255: 246)
    
    private var bottomToCenterOfStatusView: CGFloat {
        return frame.height - (autoServiceStatusView.frame.origin.y + (autoServiceStatusView.frame.height/2))
    }
    
    func configure(with autoService: AutoService) {
        self.autoService = autoService
        if let date = autoService.scheduledDate {
            scheduledDateLabel.text = hourMinuteDateFormatter.string(from: date)
        }
        
        let vehicleFormatString = NSLocalizedString("%@ • %@", comment: "Vehicle format string: 'vehicle name' • 'license plate number'")
        
        let vehicleName = autoService.vehicle?.name ?? ""
        let licensePlateNumber = autoService.vehicle?.licensePlate ?? ""
        
        vehicleLabel.text = String(format: vehicleFormatString, vehicleName, licensePlateNumber)
        userLabel.text = autoService.creator?.displayName
        locationLabel.text = autoService.location?.streetAddress ?? "location"
        oilTypeLabel.text = autoService.firstOilChange?.oilType.localizedString ?? ""
        
        let coordinate = autoService.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(region, animated: false)
    }
    
    @objc private func didSelectGetDirections() {
        autoService?.location?.openInMaps()
    }
    
}
