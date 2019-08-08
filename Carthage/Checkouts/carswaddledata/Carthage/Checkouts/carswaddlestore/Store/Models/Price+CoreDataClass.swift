//
//  Price+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

typealias PriceValues = (identifier: String, totalPrice: Int, taxes: Int, subtotal: Int, processingFee: Int, bookingFee: Int, distance: Int, oilChange: Int, couponDiscount: Int?, bookingFeeDiscount: Int?)

@objc(Price)
public final class Price: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Price.values(from: json) else { return nil }
        self.init(context: context)
        configure(from: values, json: json)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Price.values(from: json) else { throw StoreError.invalidJSON }
        configure(from: values, json: json)
    }
    
    private static func values(from json: JSONObject) -> PriceValues? {
        guard let priceJSON = json["prices"] as? JSONObject else { return nil}
        guard let totalPrice = priceJSON["total"] as? Int,
            let processingFee = priceJSON["processingFee"] as? Int,
            let bookingFee = priceJSON["bookingFee"] as? Int,
            let distance = priceJSON["distance"] as? Int,
            let oilChange = priceJSON["oilChange"] as? Int,
            let taxes = priceJSON["taxes"] as? Int,
            let subtotal = priceJSON["subtotal"] as? Int else { return nil }
        
        /// Generate id every time. Should change
        let uuid = UUID().uuidString
        
        return (uuid, totalPrice, taxes, subtotal, processingFee, bookingFee, distance, oilChange, priceJSON["discount"] as? Int, priceJSON["bookingFeeDiscount"] as? Int)
    }
    
    private func configure(from values: PriceValues, json: JSONObject)  {
        self.identifier = values.identifier
        self.total = values.totalPrice
        self.taxes = values.taxes
        self.processingFee = values.processingFee
        self.bookingFee = values.bookingFee
        self.distanceCost = values.distance
        self.oilChangeCost = values.oilChange
        self.subtotal = values.subtotal
        self.bookingFeeDiscount = values.bookingFeeDiscount
        self.couponDiscount = values.couponDiscount
        
        guard let context = managedObjectContext else { return }
        
        if let autoServiceID = json["autoServiceID"] as? String {
            self.autoService = AutoService.fetch(with: autoServiceID, in: context)
        }
    }
    
    public var totalDollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(total) / 100.0)
    }
    
    
    private let couponDiscountKey = "couponDiscount"
    
    @NSManaged private var primitiveCouponDiscount: NSNumber?
    
    public var couponDiscount: Int? {
        set {
            willChangeValue(forKey: couponDiscountKey)
            if let newValue = newValue {
                primitiveCouponDiscount = NSNumber(value: newValue)
            } else {
                primitiveCouponDiscount = nil
            }
            didChangeValue(forKey: couponDiscountKey)
        }
        get {
            willAccessValue(forKey: couponDiscountKey)
            let value = primitiveCouponDiscount
            didAccessValue(forKey: couponDiscountKey)
            
            return value?.intValue
        }
    }
    
    private let bookingFeeDiscountKey = "bookingFeeDiscount"
    
    @NSManaged private var primitiveBookingFeeDiscount: NSNumber?
    
    public var bookingFeeDiscount: Int? {
        set {
            willChangeValue(forKey: bookingFeeDiscountKey)
            if let bookingFeeDiscount = newValue {
                primitiveBookingFeeDiscount = NSNumber(value: bookingFeeDiscount)
            } else {
                primitiveBookingFeeDiscount = nil
            }
            didChangeValue(forKey: bookingFeeDiscountKey)
        }
        get {
            willAccessValue(forKey: bookingFeeDiscountKey)
            let value = primitiveBookingFeeDiscount?.intValue
            didAccessValue(forKey: bookingFeeDiscountKey)
            
            return value
        }
    }
    
}
