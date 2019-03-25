//
//  AutoServiceLocationCell.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/12/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import Store
import MapKit
import CarSwaddleUI

final class AutoServiceLocationCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var streetAddressLabel: UILabel!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    @IBOutlet private weak var distanceContentView: UIView!
    
    
    private var location: Location?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        streetAddressLabel.font = UIFont.appFont(type: .regular, size: 17)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AutoServiceLocationCell.didTapMap(_:)))
        mapView.addGestureRecognizer(tap)
        
        mapView.addAnnotation(annotation)
        
        distanceContentView.layer.cornerRadius = 6
        mapView.layer.cornerRadius = defaultCornerRadius
        
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        let view = addHairlineView(toSide: .bottom, color: .gray3, size: 1.0, insets: insets)
        view.layer.cornerRadius = 0.5
        
        selectionStyle = .none
    }
    
    private func requestRoute() {
        guard let destinationLocation = location?.clLocation else { return }
        locationManager.currentLocation(cacheOptions: .cacheElseNetwork(maxAge: 2*60)) { [weak self] location, error in
            guard let location = location else {
                // Update label
                return
            }
            let routeRequest = RouteRequest(sourceLocation: location, destinationLocation: destinationLocation) { route, error in
                let formatString = NSLocalizedString("%@ mi", comment: "number of miles shortened")
                let milesString = distanceNumberFormatter.string(from: NSNumber(value: route?.distance.metersToMiles ?? 0))
                self?.distanceLabel.text = String(format: formatString, milesString ?? "")
            }
            locationManager.queueRouteRequest(routeRequest: routeRequest)
        }
    }

    func configure(with location: Location) {
        self.location = location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1200, longitudinalMeters: 1200)
        mapView.setRegion(region, animated: false)
        streetAddressLabel.text = location.streetAddress
        requestRoute()
        
        annotation.coordinate = location.coordinate
    }
    
    private var annotation: MKPointAnnotation = MKPointAnnotation()
    
    @IBAction private func didTapMap(_ map: MKMapView) {
        location?.openInMaps()
    }
    
    @IBAction private func didTapGetDirections() {
        location?.openInMaps()
    }
    
}


extension Location {
    
    func openInMaps() {
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    var mapItem: MKMapItem {
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = streetAddress
        return mapItem
    }
    
    var placeMark: MKPlacemark {
        return MKPlacemark(coordinate: coordinate, addressDictionary:nil)
    }
    
}
