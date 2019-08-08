//
//  CouponService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation


extension NetworkRequest.Request.Endpoint {
    /*
     /api/authorities/request?authority=readAuthorities
     /api/authorities/reject
     /api/authorities/approve
     /api/authorities
     /api/authorityRequests?pending=false
     */
    private static let couponsAPI = "/api/coupons"
    fileprivate static let coupons = Request.Endpoint(rawValue: Request.Endpoint.couponsAPI)
    fileprivate static func coupons(with couponID: String) -> NetworkRequest.Request.Endpoint {
        return Request.Endpoint(rawValue: Request.Endpoint.couponsAPI + "/" + couponID)
    }
}

final public class CouponService: Service {
    
    @discardableResult
    public func getCoupons(limit: Int? = nil, offset: Int? = nil, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        if let limit = limit {
            let limitQueryItem = URLQueryItem(name: "limit", value: String(limit))
            queryItems.append(limitQueryItem)
        }
        
        if let offset = offset {
            let offsetQueryItem = URLQueryItem(name: "skip", value: String(offset))
            queryItems.append(offsetQueryItem)
        }
        
        guard let urlRequest = serviceRequest.get(with: .coupons, queryItems: queryItems) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func deleteCoupon(couponID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .coupons(with: couponID)) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func createCoupon(id: String, amountOff: Int?, percentOff: Int?, maxRedemptions: Int?, name: String, redeemBy: Date, discountBookingFee: Bool, isCorporate: Bool, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var jsonBody: [String:String] = [:]
        jsonBody["id"] = id
        if let amountOff = amountOff?.stringValue {
            jsonBody["amountOff"] = amountOff
        }
        if let percentOff = percentOff?.stringValue {
            jsonBody["percentOff"] = percentOff
        }
        if let maxRedemptions = maxRedemptions?.stringValue {
            jsonBody["maxRedemptions"] = maxRedemptions
        }
        jsonBody["name"] = name
        jsonBody["redeemBy"] = serverDateFormatter.string(from: redeemBy)
        jsonBody["discountBookingFee"] = discountBookingFee.stringValue
        jsonBody["isCorporate"] = isCorporate.stringValue
        
        guard let data = (try? JSONSerialization.data(withJSONObject: jsonBody, options: [])),
            let urlRequest = serviceRequest.post(with: .coupons, body: data, contentType: .applicationJSON) else {
                return nil
        }
        return sendWithAuthentication(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
}


extension Int {
    
    public var stringValue: String {
        return String(self)
    }
    
}

/*
 {
 "id": "testNoob",
 "amountOff": 30,
 "percentOff": null,
 "maxRedemptions": 1,
 "name": "Marks test 1",
 "redeemBy": "2019-07-31T02:38:08.948Z",
 "discountBookingFee": false
 }
 */
