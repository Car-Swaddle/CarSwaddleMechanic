//
//  OilChangePricing.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 8/21/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

public struct OilChangePricing: Codable {
    
    public init(id: String, conventional: Int, blend: Int, synthetic: Int, highMileage: Int, centsPerMile: Int, mechanicID: String) {
        self.id = id
        self.conventional = conventional
        self.blend = blend
        self.synthetic = synthetic
        self.highMileage = highMileage
        self.centsPerMile = centsPerMile
        self.mechanicID = mechanicID
    }
    
    public let id: String
    public let conventional: Int
    public let blend: Int
    public let synthetic: Int
    public let highMileage: Int
    public let centsPerMile: Int
    public let mechanicID: String
}

public struct OilChangePricingUpdate: Encodable {
    
    public init(conventional: Int, blend: Int, synthetic: Int, highMileage: Int) {
        self.conventional = conventional
        self.blend = blend
        self.synthetic = synthetic
        self.highMileage = highMileage
    }
    
    public var conventional: Int
    public var blend: Int
    public var synthetic: Int
    public var highMileage: Int
}
