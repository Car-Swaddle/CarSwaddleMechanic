//
//  NetworkRequestError.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 9/21/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]

public extension NetworkRequestError {
    public static let invalidJSON = NetworkRequestError(rawValue: "invalidJSON")
}

public struct NetworkRequestError: Error {
    public var rawValue: String
    
}

