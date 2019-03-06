//
//  TransactionMetadata+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 2/3/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias TransactionMetadataValues = (identifier: String, stripeTransactionID: String, mechanicCost: Int, drivingDistance: Int, autoServiceID: String, createdAt: Date, mechanicID: String)

@objc(TransactionMetadata)
final public class TransactionMetadata: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = TransactionMetadata.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = TransactionMetadata.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, json: json, in: context)
    }
    
    static private func values(from json: JSONObject) -> TransactionMetadataValues? {
        guard let identifier = json["id"] as? String,
            let stripeTransactionID = json["stripeTransactionID"] as? String,
            let mechanicCost = json["mechanicCost"] as? Int,
            let drivingDistance = json["drivingDistance"] as? Int,
            let autoServiceID = json["autoServiceID"] as? String,
            let mechanicID = json["mechanicID"] as? String,
            let createdAtString = json["createdAt"] as? String,
            let createdAt = serverDateFormatter.date(from: createdAtString) else { return nil }
        
        return (identifier, stripeTransactionID, mechanicCost, drivingDistance, autoServiceID, createdAt, mechanicID)
    }
    
    private func configure(with values: TransactionMetadataValues, json: JSONObject, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.stripeTransactionID = values.stripeTransactionID
        self.mechanicCost = values.mechanicCost
        self.drivingDistance = values.drivingDistance
        self.autoServiceID = values.autoServiceID
        self.mechanicID = values.mechanicID
        self.createdAt = values.createdAt
        
        if let transactionReceiptsJSON = json["transactionReceipts"] as? [JSONObject] {
            self.receipts = Set<TransactionReceipt>(TransactionReceipt.receipts(from: transactionReceiptsJSON, in: context))
        }
        self.autoService = AutoService.fetch(with: values.autoServiceID, in: context)
    }
    
    
    
}
