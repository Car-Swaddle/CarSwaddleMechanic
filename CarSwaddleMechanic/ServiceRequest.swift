//
//  ServiceRequest.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/30/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import NetworkRequest
import CarSwaddleNetworkRequest
import CarSwaddleUI

import UIKit
import Authentication
import Store
import CarSwaddleData


#if targetEnvironment(simulator)
private let localDomain = "127.0.0.1"
#else
private let localDomain = "Kyles-MacBook-Pro.local"
#endif

private let productionDomain = "api.carswaddle.com"
private let stagingDomain = "api.staging.carswaddle.com"

private let domainUserDefaultsKey = "domain"

extension Tweak {
    
    public enum ServerType {
        case local
        case production
        case staging
    }
    
    public static func currentDomainServerType() -> ServerType? {
        guard let domainString = domain.value as? String else { return nil }
        switch domainString {
        case productionDomain: return .production
        case stagingDomain: return .staging
        case localDomain: return .local
        default: return nil
        }
    }
    
    private static let domainOptions = Tweak.Options.string(values: [localDomain, productionDomain, stagingDomain])
    
    static let domain: Tweak = {
        let valueDidChange: (_ tweak: Tweak) -> Void = { tweak in
            _serviceRequest = nil
        }
        let domain = Tweak(label: "Domain", options: Tweak.domainOptions, userDefaultsKey: domainUserDefaultsKey, valueDidChange: valueDidChange, defaultValue: productionDomain, requiresAppReset: true)
        return domain
    }()
    
}

fileprivate var _serviceRequest: Request?
public var serviceRequest: Request {
    if let _serviceRequest = _serviceRequest {
        return _serviceRequest
    }
    let newServiceRequest = createServiceRequest()
    _serviceRequest = newServiceRequest
    return newServiceRequest
}

public func createServiceRequest() -> Request {
    #if DEBUG
    let domain = (Tweak.domain.value as? String) ?? productionDomain
    if domain == localDomain {
        let request = Request(domain: domain)
        request.port = 3000
        request.timeout = 15
        request.defaultScheme = .http
        return request
    } else {
        let request = Request(domain: domain)
        request.timeout = 15
        request.defaultScheme = .https
        return request
    }
    #else
    
    let request = Request(domain: productionDomain)
    request.timeout = 15
    request.defaultScheme = .https
    return request
    
    #endif
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
