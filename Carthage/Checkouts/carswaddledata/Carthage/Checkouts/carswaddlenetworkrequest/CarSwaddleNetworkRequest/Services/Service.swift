//
//  Service.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import NetworkRequest

public class Service {
    
    public private(set) var serviceRequest: Request
    
    public init(serviceRequest: Request) {
        self.serviceRequest = serviceRequest
    }
    
}
