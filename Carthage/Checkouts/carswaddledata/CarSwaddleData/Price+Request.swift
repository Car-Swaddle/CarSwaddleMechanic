//
//  Price+Request.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 12/20/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreLocation
import CoreData

final public class PriceNetwork: Network {
    
    private var priceService: PriceService
    
    override public init(serviceRequest: Request) {
        self.priceService = PriceService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func requestPrice(mechanicID: String, oilType: OilType, location: Location, couponCode: String?, in context: NSManagedObjectContext, completion: @escaping (_ priceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return self.requestPrice(mechanicID: mechanicID, oilType: oilType, location: location.coordinate, couponCode: couponCode, in: context, completion: completion)
    }
    
    @discardableResult
    public func requestPrice(mechanicID: String, oilType: OilType, location: CLLocationCoordinate2D, couponCode: String?, in context: NSManagedObjectContext, completion: @escaping (_ priceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return priceService.getPrice(mechanicID: mechanicID, oilType: oilType.rawValue, location: location, couponCode: couponCode) { [weak self] json, error in
            self?.complete(json: json, error: error, in: context, completion: completion)
        }
    }
    
    private func complete(json: JSONObject?, error: Error?, in context: NSManagedObjectContext, completion: @escaping (_ priceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) {
        context.performOnImportQueue {
            var priceObjectID: NSManagedObjectID?
            var completionError: Error?
            defer {
                DispatchQueue.global().async {
                    completion(priceObjectID, error)
                }
            }
            guard let json = json,
                let price = Price.fetchOrCreate(json: json, context: context) else { return }
            context.persist()
            priceObjectID = price.objectID
        }
    }
    
}
