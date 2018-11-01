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

private let defaultID = "RegionID"


final class ServiceRegionViewController: UIViewController, StoryboardInstantiating {

    @IBOutlet private weak var mapView: MKMapView!
    
    private var serviceRegion: Region?
    
    private var hasFetchedRegion: Bool = false
    
    private var regionNetwork = RegionNetwork(serviceRequest: serviceRequest)
    
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
        requestMapRegion()
        setupRegionSelection()
        setupBarButtons()
        mapView.delegate = self
    }
    
    private func setupBarButtons() {
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save the region the mechanic has chosen to serve."), style: .plain, target: self, action: #selector(ServiceRegionViewController.didTapSave))
        navigationItem.rightBarButtonItem = saveButton
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel sacing the region"), style: .plain, target: self, action: #selector(ServiceRegionViewController.didTapCancel))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func didTapCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapSave() {
        let previousButton = navigationItem.rightBarButtonItem
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.startAnimating()
        let animatingButton = UIBarButtonItem(customView: activityView)
        navigationItem.rightBarButtonItem = animatingButton
        saveCurrentServiceRegionToServer { [weak self] error in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem = previousButton
                if error == nil {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func saveCurrentServiceRegionToServer(completion: @escaping (_ error: Error?) -> Void) {
        guard let serviceRegion = serviceRegion else { return }
        let mapViewRegion = mapView.convert(circleView.frame, toRegionFrom: view)
        
        serviceRegion.latitude = mapViewRegion.center.latitude
        serviceRegion.longitude = mapViewRegion.center.longitude
        serviceRegion.radius = mapViewRegion.latitudinalDistance/2
        
        store.mainContext.persist()
        
        let regionObjectID = serviceRegion.objectID
        
        store.privateContext { [weak self] context in
            guard let region = context.object(with: regionObjectID) as? Region else { return }
            self?.regionNetwork.postRegion(region: region, in: context) { newRegionID, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let newRegionID = newRegionID {
                    context.perform {
                        guard let region = context.object(with: newRegionID) as? Region,
                            let mechanic = Mechanic.currentLoggedInMechanic(in: context) else { return }
                        mechanic.serviceRegion = region
                        context.persist()
                    }
                }
                completion(error)
            }
        }
    }
    
    lazy private var circleHeightConstraint: NSLayoutConstraint = circleView.heightAnchor.constraint(equalToConstant: 60)
    
    private func setupRegionSelection() {
        view.addSubview(circleView)
        circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        circleHeightConstraint.isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ServiceRegionViewController.didPan(_:)))
        circleView.gripView.addGestureRecognizer(panGesture)
    }
    
    private var startingPoint: CGPoint = .zero
    
    @objc private func didPan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            startingPoint = .zero
        case .changed:
            let panLocation = pan.location(in: view)
            let newRadius = panLocation.x - view.center.x + startingPoint.x
            circleHeightConstraint.constant = max(75, min(view.frame.width - 30, newRadius*2))
        case .ended:
            if hasFetchedRegion {
                saveLocalServiceRegion()
            }
        case .failed, .possible, .cancelled:
            break
        }
    }
    
    private func saveLocalServiceRegion() {
        let coordinate = mapView.convert(circleView.frame, toRegionFrom: view)
        serviceRegion?.latitude = coordinate.center.latitude
        serviceRegion?.longitude = coordinate.center.longitude
        serviceRegion?.radius = coordinate.span.longitudinalKilometers.kilometersToMeters/2
        serviceRegion?.managedObjectContext?.persist()
        
        if let serviceRegion = serviceRegion {
            print("serviceRegin: \(serviceRegion)")
        }
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ServiceRegionViewController.didChangeLocationAccess(_:)), name: .changedLocationAuthorizationStatus, object: nil)
    }
    
    @objc private func didChangeLocationAccess(_ notification: Notification) {
        switch location.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            updateMapViewToUsersLocation(animated: true)
        default: break
        }
    }
    
    private func requestMapRegion() {
        hasFetchedRegion = false
        store.mainContext { [weak self] privateContext in
            self?.regionNetwork.getRegion(in: privateContext) { [weak self] regionObjectID, error in
                store.mainContext { context in
                    if let regionObjectID = regionObjectID, let region = context.object(with: regionObjectID) as? Region {
                        self?.serviceRegion = region
                        self?.updateMapView(to: region, animated: false)
                    } else {
                        self?.updateMapViewToUsersLocation(animated: false)
                    }
                    self?.saveLocalServiceRegion()
                    self?.hasFetchedRegion = true
                }
            }
        }
    }
    
    private func updateMapView(to region: Region, animated: Bool) {
        let mapViewSpan: CLLocationDistance = region.radius*5
        let thatThing = MKCoordinateRegion(center: region.coordinate, latitudinalMeters: mapViewSpan, longitudinalMeters: mapViewSpan)
        mapView.setRegion(thatThing, animated: animated)
        mapView.layoutIfNeeded()
        let circleCoordinateRegion = MKCoordinateRegion(center: region.coordinate, latitudinalMeters: 100, longitudinalMeters: region.radius*2)
        let value = mapView.convert(circleCoordinateRegion, toRectTo: view)
        circleHeightConstraint.constant = value.width
    }
    
    private func updateMapViewToUsersLocation(animated: Bool) {
        location.currentLocation(cacheOptions: .cacheElseNetwork(maxAge: .hour)) { [weak self] location, error in
            DispatchQueue.main.async {
                guard let self = self, let location = location else { return }
                let region = Region(context: store.mainContext)
                region.identifier = defaultID
                region.latitude = location.coordinate.latitude
                region.longitude = location.coordinate.longitude
                region.radius = defaultRegionRadius
                
                self.serviceRegion = region
                store.mainContext.persist()
                self.mapView.setRegion(self.coordinateRegion(with: region.coordinate), animated: false)
            }
        }
    }
    
    private func coordinateRegion(with coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinate, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
    }
    
}

extension ServiceRegionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
        if hasFetchedRegion {
            saveLocalServiceRegion()
        }
    }
    
}




class CircleView: UIView {
    
    var gripView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.6, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
        clipsToBounds = true
//        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubview()
    }
    
    private func setupSubview() {
        addSubview(gripView)
        gripView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        gripView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        gripView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        gripView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if gripView.frame.contains(point) {
            return gripView
        }
        return nil
    }
    
}


extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
}
