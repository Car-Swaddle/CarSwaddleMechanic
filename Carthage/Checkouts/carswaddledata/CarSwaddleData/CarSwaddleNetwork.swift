//
//  Network.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 11/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import CoreData
import Store
import CarSwaddleNetworkRequest

open class Network {
    
    public let serviceRequest: Request
    
    public init(serviceRequest: Request) {
        self.serviceRequest = serviceRequest
    }
    
}
