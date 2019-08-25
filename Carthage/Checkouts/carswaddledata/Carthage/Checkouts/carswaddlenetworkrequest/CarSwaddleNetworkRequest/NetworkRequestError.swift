//
//  NetworkRequestError.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

public extension NetworkRequestError {
    static let invalidJSON = NetworkRequestError(rawValue: "invalidJSON")
    static let invalidResponse = NetworkRequestError(rawValue: "invalidResponse")
    static let unableToCreateURLRequest = NetworkRequestError(rawValue: "unableToCreateURLRequest")
}

public struct NetworkRequestError: Error {
    public var rawValue: String
}

