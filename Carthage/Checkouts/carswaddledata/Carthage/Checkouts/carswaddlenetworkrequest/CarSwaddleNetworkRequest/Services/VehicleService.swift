//
//  VehicleService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 11/15/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit

extension NetworkRequest.Request.Endpoint {
    fileprivate static let vehicle = Request.Endpoint(rawValue: "/api/vehicle")
    fileprivate static let vehicles = Request.Endpoint(rawValue: "/api/vehicles")
}

struct VehicleServiceError: Error {
    let rawValue: String
    static let nothingDeletedError = VehicleServiceError(rawValue: "nothigDeletedError")
}

final public class VehicleService: Service {
    
    @discardableResult
    public func getVehicles(limit: Int = 100, offset: Int = 0, completion: @escaping JSONArrayCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.get(with: .vehicles) else { return nil }
        let task = sendWithAuthentication(urlRequest: urlRequest) { [weak self] data, error in
            self?.completeWithJSONArray(data: data, error: error, completion: completion)
        }
        return task
    }
    
    @discardableResult
    public func getVehicle(vehicleID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "id", value: vehicleID))
        guard var urlRequest = serviceRequest.get(with: .vehicle, queryItems: queryItems) else { return nil }
        do { try urlRequest.authenticate() } catch { print("couldn't authenticate") }
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func postVehicle(name: String, licensePlate: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        return postVehicle(name: name, licensePlate: licensePlate, vin: nil, completion: completion)
    }
    
    @discardableResult
    public func postVehicle(name: String, vin: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        return postVehicle(name: name, licensePlate: nil, vin: vin, completion: completion)
    }
    
    private func postVehicle(name: String?, licensePlate: String?, vin: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json: JSONObject = [:]
        if let name = name { json["name"] = name }
        if let licensePlate = licensePlate { json["licensePlate"] = licensePlate }
        if let vin = vin { json["vin"] = vin }
        
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard var urlRequest = serviceRequest.post(with: .vehicle, body: body, contentType: .applicationJSON) else { return nil }
        do { try urlRequest.authenticate() } catch { print("couldn't authenticate") }
        let task = serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
        return task
    }
    
    @discardableResult
    public func putVehicle(vehicleID: String, name: String?, licensePlate: String?, vin: String?, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        var json: JSONObject = [:]
        if let name = name { json["name"] = name }
        if let licensePlate = licensePlate { json["licensePlate"] = licensePlate }
        if let vin = vin { json["vin"] = vin }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "id", value: vehicleID))
        
        guard let body = (try? JSONSerialization.data(withJSONObject: json, options: [])) else { return nil }
        guard var urlRequest = serviceRequest.put(with: .vehicle, queryItems: queryItems, body: body, contentType: .applicationJSON) else { return nil }
        do { try urlRequest.authenticate() } catch { print("couldn't authenticate") }
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONObject else {
                    completion(nil, error)
                    return
            }
            completion(json, error)
        }
    }
    
    @discardableResult
    public func deleteVehicle(vehicleID: String, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "id", value: vehicleID))
        
        guard var urlRequest = serviceRequest.delete(with: .vehicle, queryItems: queryItems, body: nil) else { return nil }
        do { try urlRequest.authenticate() } catch { print("couldn't authenticate") }
        return serviceRequest.send(urlRequest: urlRequest) { data, error in
            guard let data = data,
                let value = String(data: data, encoding: .utf8),
                let numberOfDeletedVehicles = Int(value) else {
                    completion(error)
                    return
            }
            if numberOfDeletedVehicles == 1 {
                completion(error)
            } else {
                completion(VehicleServiceError.nothingDeletedError)
            }
        }
    }
    
}
