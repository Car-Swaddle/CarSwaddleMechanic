//
//  Service.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import NetworkRequest

extension Notification.Name {
    public static let serviceRequestDidChange: Notification.Name = Notification.Name(rawValue: "serviceRequestDidChange")
}

public class Service {
    
    public static let newServiceRequestKey: String = "newServiceRequestObject"
    
    public private(set) var serviceRequest: Request
    
    public init(serviceRequest: Request) {
        self.serviceRequest = serviceRequest
        NotificationCenter.default.addObserver(self, selector: #selector(Service.updateServiceRequest(_:)), name: .serviceRequestDidChange, object: nil)
    }
    
    @objc private func updateServiceRequest(_ notification: Notification) {
        print("update")
        guard let newServiceRequest = notification.userInfo?[Service.newServiceRequestKey] as? Request else {
            return
        }
        self.serviceRequest = newServiceRequest
    }
    
}
