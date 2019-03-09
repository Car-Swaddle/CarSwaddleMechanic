//
//  StripeService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 12/22/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let ephemeralKeys = Request.Endpoint(rawValue: "/api/stripe/ephemeral-keys")
    fileprivate static let verification = Request.Endpoint(rawValue: "/api/stripe/verification")
    fileprivate static let balance = Request.Endpoint(rawValue: "/api/stripe/balance")
    fileprivate static let transactions = Request.Endpoint(rawValue: "/api/stripe/transactions")
    fileprivate static let transactionDetails = Request.Endpoint(rawValue: "/api/stripe/transaction-details")
    fileprivate static let payouts = Request.Endpoint(rawValue: "/api/stripe/payouts")
    fileprivate static let externalAccount = Request.Endpoint(rawValue: "/api/stripe/externalAccount")
}

private let metersToMilesConstant: CGFloat = 1609.344;

final public class StripeService: Service {
    
    @discardableResult
    public func getKeys(apiVersion: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "apiVersion", value: apiVersion)]
        guard let urlRequest = serviceRequest.post(with: .ephemeralKeys, queryItems: queryItems, body: Data()) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getVerification(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .verification) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getBalance(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .balance) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getTransactions(startingAfterID: String? = nil, payoutID: String? = nil, limit: Int? = nil, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        
        if let startingAfterID = startingAfterID {
            queryItems.append(URLQueryItem(name: "startingAfterID", value: startingAfterID))
        }
        if let payoutID = payoutID {
            queryItems.append(URLQueryItem(name: "payoutID", value: payoutID))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        guard let urlRequest = serviceRequest.get(with: .transactions, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getTransactionDetails(transactionID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "transactionID", value: transactionID)]
        guard let urlRequest = serviceRequest.get(with: .transactionDetails, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getBankAccount(completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .externalAccount) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    
    @discardableResult
    public func updateTransactionDetails(transactionID: String, mechanicCostCents: Int?, drivingDistanceMiles: Int?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        
        var distanceInMeters: Int?
        if let drivingDistanceMiles = drivingDistanceMiles {
            distanceInMeters = Int(ceil(CGFloat(drivingDistanceMiles) * metersToMilesConstant))
        }
        
        return updateTransactionDetails(transactionID: transactionID, mechanicCostCents: mechanicCostCents, drivingDistanceMeters: distanceInMeters, completion: completion)
    }
    
    /// - Parameters:
    ///   - mechanicCost: In cents
    ///   - drivingDistance: In meters
    @discardableResult
    public func updateTransactionDetails(transactionID: String, mechanicCostCents: Int?, drivingDistanceMeters: Int?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var body: JSONObject = [
            "transactionID": transactionID
        ]
        
        if let cost = mechanicCostCents {
            body["cost"] = String(cost)
        }
        if let distance = drivingDistanceMeters {
            body["distance"] = String(distance)
        }
        
        guard let data = (try? JSONSerialization.data(withJSONObject: body, options: [])),
            let urlRequest = serviceRequest.patch(with: .transactionDetails, body: data, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getPayouts(startingAfterID: String? = nil, status: String? = nil, limit: Int? = nil, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        
        if let startingAfterID = startingAfterID {
            queryItems.append(URLQueryItem(name: "startingAfterID", value: startingAfterID))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        guard let urlRequest = serviceRequest.get(with: .payouts, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
}
