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

public var serviceRequest: Request = {
    return createServiceRequest()
}()

public func createServiceRequest() -> Request {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}

public func finishTasksAndInvalidate() {
    serviceRequest.urlSession.finishTasksAndInvalidate()
    serviceRequest = createServiceRequest()
}
