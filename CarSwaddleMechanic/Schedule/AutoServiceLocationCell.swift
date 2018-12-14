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
    
    private var location: Location?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AutoServiceLocationCell.didTapMap(_:)))
        mapView.addGestureRecognizer(tap)
        
    }

    func configure(with location: Location) {
        self.location = location
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        streetAddressLabel.text = location.streetAddress
    }
    
    @IBAction private func didTapMap(_ map: MKMapView) {
        
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
