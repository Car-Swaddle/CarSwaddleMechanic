//
//  Price+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

typealias PriceValues = (identifier: String, totalPrice: Int)

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
        guard let id = json.identifier,
            let totalPrice = json["totalPrice"] as? Int else { return nil }
        return (id, totalPrice)
    }
    
    private func configure(from values: PriceValues, json: JSONObject)  {
        self.identifier = values.identifier
        self.totalPrice = values.totalPrice
        
        guard let context = managedObjectContext else { return }
        
        for previousPricePart in parts {
            context.delete(previousPricePart)
        }
        
        if let pricePartsJSONArray = json["priceParts"] as? [JSONObject] {
            for pricePartJSON in pricePartsJSONArray {
                let pricePart = PricePart(json: pricePartJSON, context: context)
                pricePart?.price = self
            }
        }
        
        if let autoServiceID = json["autoServiceID"] as? String {
            self.autoService = AutoService.fetch(with: autoServiceID, in: context)
        }
    }
    
    public var totalDollarValue: NSDecimalNumber {
        return NSDecimalNumber(value: Float(totalPrice) / 100.0)
    }
    
}
