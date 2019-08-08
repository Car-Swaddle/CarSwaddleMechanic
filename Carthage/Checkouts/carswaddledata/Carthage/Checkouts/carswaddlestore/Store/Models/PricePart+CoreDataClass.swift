//
//  PricePart+CoreDataClass.swift
//  
//
//  Created by Kyle Kendall on 9/16/18.
//
//

import Foundation
import CoreData

//@objc(PricePart)
//public final class PricePart: NSManagedObject {
//    
//    public convenience init(key: String, value: Int, in context: NSManagedObjectContext) {
//        self.init(context: context)
//        self.key = key
//        self.value = value
//    }
//    
//    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
//        guard let key = json["key"] as? String,
//            let value = json["value"] as? Int else { return nil }
//        self.init(key: key, value: value, in: context)
//    }
//    
//    public static let laborKey = "labor"
//    public static let oilFilterKey = "oilFilter"
//    public static let distanceKey = "distance"
//    public static let oilKey = "oil"
//    public static let subtotalKey = "subtotal"
//    public static let bookingFeeKey = "bookingFee"
//    public static let processingFeeKey = "processingFee"
//    
//    public static let oilChangeKey = "oilChange"
//    public static let oilChangeHighMileageKey = "oilChangeHighMileage"
//    public static let oilChangeConventionalKey = "oilChangeConventional"
//    public static let oilChangeSyntheticKey = "oilChangeSynthetic"
//    public static let oilChangeBlendKey = "oilChangeBlend"
//    
//    public var isPartOfSubtotal: Bool {
//        return PricePart.subtotalKeys.contains(key)
//    }
//    
//    private static var subtotalKeys: [String] {
//        return [subtotalKey, bookingFeeKey, processingFeeKey]
//    }
//    
//    public var localizedKey: String? {
//        switch key {
//        case PricePart.laborKey: return NSLocalizedString("Labor", comment: "Price part key")
//        case PricePart.oilFilterKey: return NSLocalizedString("Oil filter", comment: "Price part key")
//        case PricePart.distanceKey: return NSLocalizedString("Distance", comment: "Price part key")
//        case PricePart.oilKey: return NSLocalizedString("Oil", comment: "Price part key")
//        case PricePart.subtotalKey: return NSLocalizedString("Subtotal", comment: "Price part key")
//        case PricePart.bookingFeeKey: return NSLocalizedString("Booking fee", comment: "Price part key")
//        case PricePart.processingFeeKey: return NSLocalizedString("Processing fee", comment: "Price part key")
//        case PricePart.oilChangeHighMileageKey: return NSLocalizedString("Oil change high mileage", comment: "Price part key")
//        case PricePart.oilChangeKey: return NSLocalizedString("Oil change", comment: "Price part key")
//        case PricePart.oilChangeConventionalKey: return NSLocalizedString("Synthetic oil change", comment: "Price part key")
//        case PricePart.oilChangeSyntheticKey: return NSLocalizedString("Conventional oil change", comment: "Price part key")
//        case PricePart.oilChangeBlendKey: return NSLocalizedString("Blend oil change", comment: "Price part key")
//        default:
//            assert(false, "We do not have \(key) yet! Please add it \(#function) \(#line)")
//            return nil
//        }
//    }
//    
//    public var dollarValue: NSDecimalNumber {
//        return NSDecimalNumber(value: Float(value) / 100.0)
//    }
//    
//}
