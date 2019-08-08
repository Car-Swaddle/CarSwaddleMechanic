//
//  TypeAliases.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 10/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

public typealias JSONCompletion = (_ json: JSONObject?, _ error: Error?) -> Void
public typealias JSONArrayCompletion = (_ jsonArray: [JSONObject]?, _ error: Error?) -> Void
public typealias StringArrayCompletion = (_ stringArray: [String]?, _ error: Error?) -> Void
public typealias JSONObject = [String: Any]
public typealias QueryItems = [String: String]
