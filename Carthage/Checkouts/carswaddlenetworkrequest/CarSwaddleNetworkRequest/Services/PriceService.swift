//
//  PriceService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 12/18/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import MapKit

extension NetworkRequest.Request.Endpoint {
    fileprivate static let price = Request.Endpoint(rawValue: "/api/price")
}

public enum PriceError: String, Error {
    case invalidCouponCode = "INCORRECT_CODE"
    case expired = "EXPIRED"
    case invalidMechanic = "INCORRECT_MECHANIC"
    case depletedRedemptions = "DEPLETED_REDEMPTIONS"
    case couponCodeNotFound = "OTHER"
}

final public class PriceService: Service {
    
    @discardableResult
    public func getPrice(mechanicID: String, oilType: String, location: CLLocationCoordinate2D, couponCode: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        let locationJSON: JSONObject = ["latitude": location.latitude, "longitude": location.longitude]
        var json: JSONObject = ["mechanicID": mechanicID, "oilType": oilType, "location": locationJSON]
        if let couponCode = couponCode {
            json["coupon"] = couponCode
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .price, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithPriceJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getPrice(mechanicID: String, oilType: String, locationID: String, couponCode: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json: JSONObject = ["mechanicID": mechanicID, "oilType": oilType, "locationID": locationID]
        if let couponCode = couponCode {
            json["coupon"] = couponCode
        }
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])),
            let urlRequest = serviceRequest.post(with: .price, body: body, contentType: .applicationJSON) else { return nil }
        return sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithPriceJSON(data: data, error: error, completion: completion)
        }
    }
    
    func completeWithPriceJSON(data: Data?, error: Error?, completion: @escaping (_ json: JSONObject?, _ error: Error?) -> Void) {
        var error = error
        guard let data = data,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                completion(nil, error)
                return
        }
        if error != nil, let errorCode = json["code"] as? String, let priceError = PriceError(rawValue: errorCode) {
            error = priceError
        }
        completion(json, error)
    }
    
}
