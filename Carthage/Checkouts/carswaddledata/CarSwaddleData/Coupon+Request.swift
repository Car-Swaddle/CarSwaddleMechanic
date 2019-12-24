//
//  Coupon+Request.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreData

final public class CouponNetwork: Network {
    
    private var couponService: CouponService
    
    override public init(serviceRequest: Request) {
        self.couponService = CouponService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getCoupons(limit: Int? = nil, offset: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ couponObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return couponService.getCoupons(limit: limit, offset: offset) { json, error in
            context.performOnImportQueue {
                let couponObjectIDs = Coupon.fetchOrCreate(with: (json?["coupons"] as? [JSONObject]) ?? [], in: context)
                context.persist()
                DispatchQueue.global().async {
                    completion(couponObjectIDs, error)
                }
            }
        }
    }
    
    @discardableResult
    public func getSharableCoupons(limit: Int? = nil, offset: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ couponObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return couponService.getSharableCoupons(limit: limit) { json, error in
            context.performOnImportQueue {
                let couponObjectIDs = Coupon.fetchOrCreate(with: (json?["coupons"] as? [JSONObject]) ?? [], in: context)
                context.persist()
                DispatchQueue.global().async {
                    completion(couponObjectIDs, error)
                }
            }
        }
    }
    
    public enum CouponDiscount {
        case amountOff(value: Int)
        case percentOff(value: Int)
    }
    
    
    @discardableResult
    public func createCoupon(id: String, discount: CouponDiscount, maxRedemptions: Int?, name: String, redeemBy: Date, discountBookingFee: Bool, isCorporate: Bool, in context: NSManagedObjectContext, completion: @escaping (_ couponObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let amountOff: Int?
        let percentOff: Int?
        
        switch discount {
        case .amountOff(let value):
            amountOff = value
            percentOff = nil
        case .percentOff(let value):
            amountOff = nil
            percentOff = value
        }
        
        return couponService.createCoupon(id: id, amountOff: amountOff, percentOff: percentOff, maxRedemptions: maxRedemptions, name: name, redeemBy: redeemBy, discountBookingFee: discountBookingFee, isCorporate: isCorporate) { json, error in
            context.performOnImportQueue {
                var couponObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(couponObjectID, error)
                    }
                }
                guard let json = json?["coupon"] as? JSONObject,
                    let coupon = Coupon.fetchOrCreate(json: json, context: context) else { return }
                context.persist()
                couponObjectID = coupon.objectID
            }
        }
    }
    
    @discardableResult
    public func deleteCoupon(id: String, in context: NSManagedObjectContext, completion: @escaping (_ error: Error?) -> Void) -> URLSessionDataTask? {
        return couponService.deleteCoupon(couponID: id) { json, error in
            context.performOnImportQueue {
                defer {
                    DispatchQueue.global().async {
                        completion(error)
                    }
                }
                if let couponToDelete = Coupon.fetch(with: id, in: context) {
                    context.delete(couponToDelete)
                }
            }
        }
    }
    
}


//public extension Array where Iterator.Element: NSManagedObjectFetchable {
//
//    func fetchOrCreate(with jsonArray: [JSONObject], in context: NSManagedObjectContext) -> [NSManagedObjectID] {
//        var objectIDs: [NSManagedObjectID] = []
//        for json in jsonArray {
//            guard let object = .fetchOrCreate(json: json, context: context) else { continue }
//            if object.objectID.isTemporaryID == true {
//                try? context.obtainPermanentIDs(for: [object])
//            }
//            objectIDs.append(object.objectID)
//        }
//        return objectIDs
//    }
//
//}

public extension JSONInitable where Self: NSManagedObject {
    
    static func fetchOrCreate(with jsonArray: [JSONObject], in context: NSManagedObjectContext) -> [NSManagedObjectID] {
        var objectIDs: [NSManagedObjectID] = []
        for json in jsonArray {
            guard let object = Self.fetchOrCreate(json: json, context: context) else { continue }
            if object.objectID.isTemporaryID == true {
                try? context.obtainPermanentIDs(for: [object])
            }
            objectIDs.append(object.objectID)
        }
        return objectIDs
    }
    
}
