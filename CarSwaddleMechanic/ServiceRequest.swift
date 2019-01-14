//
//  ServiceRequest.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import NetworkRequest
import CarSwaddleNetworkRequest


#if targetEnvironment(simulator)
private let localDomain = "127.0.0.1"
#else
private let localDomain = "Kyles-MacBook-Pro.local"
#endif

private let hostedDomain = "car-swaddle.herokuapp.com"


private let useLocalServerKey = "useLocalServer"

public var useLocalServer: Bool {
    get {
        return UserDefaults.standard.bool(forKey: useLocalServerKey)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: useLocalServerKey)
    }
}



var _serviceRequest: Request?
public var serviceRequest: Request {
    if let _serviceRequest = _serviceRequest {
        return _serviceRequest
    }
    let newServiceRequest = createServiceRequest()
    _serviceRequest = newServiceRequest
    return newServiceRequest
}

public func createServiceRequest() -> Request {
    if useLocalServer {
        let request = Request(domain: localDomain)
        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .http
        return request
    } else {
        let request = Request(domain: hostedDomain)
        request.timeout = 15
        request.defaultScheme = .https
        return request
    }
}




public func finishTasksAndInvalidate(completion: @escaping () -> Void) {
    serviceRequest.urlSession.getTasksWithCompletionHandler { dataTask, uploadTask, downloadTask in
        for task in dataTask {
            task.cancel()
        }
        for task in uploadTask {
            task.cancel()
        }
        for task in downloadTask {
            task.cancel()
        }
        completion()
    }
}
