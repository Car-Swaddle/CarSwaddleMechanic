//
//  ServiceRegionViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit
import CarSwaddleUI
import CoreLocation
import Store
import CarSwaddleData

private let locationDistance: CLLocationDistance = 30 * .mile

private let defaultRegionRadius: Double = 12.0

final class ServiceRegionViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var mapView: MKMapView!
    
    private var serviceRegion: Region?
    
    private var regionNetwork = RegionNetwork()
    
    private var circleView: CircleView = {
        let view = CircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.4
        view.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        location.promptUserForLocationAccess()
        updateMapRegion()
        setupRegionSelection()
    }
    
    lazy private var circleHeightConstraint: NSLayoutConstraint = circleView.heightAnchor.constraint(equalToConstant: 60)
    
    private func setupRegionSelection() {
        view.addSubview(circleView)
        circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        circleHeightConstraint.isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ServiceRegionViewController.didPan(_:)))
        circleView.addGestureRecognizer(panGesture)
    }
    
    @objc private func didPan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            break
        case .changed:
            let panLocation = pan.location(in: view)
            circleHeightConstraint.constant = panLocation.distance(to: view.center)*2
        case .ended:
            break
        case .failed, .possible, .cancelled:
            break
        }
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ServiceRegionViewController.didChangeLocationAccess(_:)), name: .changedLocationAuthorizationStatus, object: nil)
    }
    
    @objc private func didChangeLocationAccess(_ notification: Notification) {
        switch location.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            updateMapRegionToUsersLocation(animated: true)
        default: break
        }
    }
    
    private func updateMapRegion() {
        if let region = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.serviceRegion {
            serviceRegion = region
            updateMapRegion(to: region, animated: false)
        } else {
            updateMapRegionToUsersLocation(animated: false)
        }
    }
    
    private func updateMapRegion(to region: Region, animated: Bool) {
        self.mapView.setRegion(coordinateRegion(with: region.coordinate), animated: animated)
    }
    
    private func updateMapRegionToUsersLocation(animated: Bool) {
        location.currentLocation(cacheOptions: .cacheElseNetwork(maxAge: .hour)) { [weak self] location, error in
            DispatchQueue.main.async {
                guard let self = self, let location = location else { return }
                let region = Region(context: store.mainContext)
                region.latitude = location.coordinate.latitude
                region.longitude = location.coordinate.longitude
                region.radius = defaultRegionRadius
                
                self.serviceRegion = region
                store.mainContext.persist()
                self.mapView.setRegion(self.coordinateRegion(with: region.coordinate), animated: true)
            }
        }
    }
    
    private func coordinateRegion(with coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinate, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
    }
    
    private func updateRegion() {
        guard let serviceRegion = serviceRegion else { return }
        
        store.privateContext { [weak self] context in
            self?.regionNetwork.postRegion(region: serviceRegion, in: context) { objectID, error in
                DispatchQueue.main.async {
                    if let objectID = objectID, let newRegion = store.mainContext.object(with: objectID) as? Region {
                        if let prevRegion = self?.serviceRegion {
                            store.mainContext.delete(prevRegion)
                        }
                        self?.serviceRegion = newRegion
                        store.mainContext.persist()
                    }
                }
            }
        }
    }
    
}

extension ServiceRegionViewController: MKMapViewDelegate {
    
    
    
}




class CircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
    
}


extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
}
