//
//  ServiceRequest.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import NetworkRequest

#if targetEnvironment(simulator)
private let domain = "127.0.0.1"
#else
private let domain = "Kyles-MacBook-Pro.local"
#endif

public let serviceRequest: Request = {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}()
