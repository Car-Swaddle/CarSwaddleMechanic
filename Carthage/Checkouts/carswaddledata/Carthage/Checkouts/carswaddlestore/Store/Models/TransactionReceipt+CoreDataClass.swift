//
//  TransactionReceipt+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 2/3/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias TransactionReceiptValues = (identifier: String, receiptPhotoID: String, createdAt: Date)

@objc(TransactionReceipt)
final public class TransactionReceipt: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public static func receipts(from jsonArray: [JSONObject], in context: NSManagedObjectContext) -> [TransactionReceipt] {
        var receipts: [TransactionReceipt] = []
        for json in jsonArray {
            guard let receipt = TransactionReceipt.fetchOrCreate(json: json, context: context) else { continue }
            receipts.append(receipt)
        }
        return receipts
    }
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = TransactionReceipt.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = TransactionReceipt.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, json: json, in: context)
    }
    
    static private func values(from json: JSONObject) -> TransactionReceiptValues? {
        guard let identifier = json["id"] as? String,
            let receiptPhotoID = json["receiptPhotoID"] as? String,
            let createdAtString = json["createdAt"] as? String,
            let createdAt = serverDateFormatter.date(from: createdAtString) else { return nil }
        return (identifier, receiptPhotoID, createdAt)
    }
    
    private func configure(with values: TransactionReceiptValues, json: JSONObject, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.receiptPhotoID = values.receiptPhotoID
        self.createdAt = values.createdAt
        
        if let transactionMetadataID = json["transactionMetadataID"] as? String,
            let transactionMetadata = TransactionMetadata.fetch(with: transactionMetadataID, in: context) {
            self.transactionMetadata = transactionMetadata
        }
    }
    
    
    public static func fetchReceipts(for transactionMetadata: TransactionMetadata, in context: NSManagedObjectContext) -> [TransactionReceipt] {
        return (try? context.fetch(TransactionReceipt.fetchRequest(for: transactionMetadata))) ?? []
    }
    
    public static func fetchRequest(for transactionMetadata: TransactionMetadata) -> NSFetchRequest<TransactionReceipt> {
        let fetchRequest: NSFetchRequest<TransactionReceipt> = TransactionReceipt.fetchRequest()
        fetchRequest.sortDescriptors = [TransactionReceipt.createdAtSortDescriptor]
        fetchRequest.predicate = TransactionReceipt.predicate(for: transactionMetadata)
        return fetchRequest
    }
    
    public static func fetchReceipts(forTransactionMetadataID transactionMetadataID: String, in context: NSManagedObjectContext) -> [TransactionReceipt] {
        return (try? context.fetch(TransactionReceipt.fetchRequest(forTransactionMetadataID: transactionMetadataID))) ?? []
    }
    
    public static func fetchRequest(forTransactionMetadataID transactionMetadataID: String) -> NSFetchRequest<TransactionReceipt> {
        let fetchRequest: NSFetchRequest<TransactionReceipt> = TransactionReceipt.fetchRequest()
        fetchRequest.sortDescriptors = [TransactionReceipt.createdAtSortDescriptor]
        fetchRequest.predicate = TransactionReceipt.predicate(forTransactionMetadataID: transactionMetadataID)
        return fetchRequest
    }
    
    
    public static func fetchAll(in context: NSManagedObjectContext) -> [TransactionReceipt] {
        return (try? context.fetch(TransactionReceipt.allFetchRequest())) ?? []
    }
    
    public static func allFetchRequest() -> NSFetchRequest<TransactionReceipt> {
        let fetchRequest: NSFetchRequest<TransactionReceipt> = TransactionReceipt.fetchRequest()
        fetchRequest.sortDescriptors = [TransactionReceipt.createdAtSortDescriptor]
        return fetchRequest
    }
    
    public static var createdAtSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(TransactionReceipt.createdAt), ascending: true)
    }
    
    public static func predicate(forTransactionMetadataID transactionMetadataID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(TransactionReceipt.transactionMetadata.identifier), transactionMetadataID)
    }
    
    public static func predicate(for transactionMetadata: TransactionMetadata) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(TransactionReceipt.transactionMetadata), transactionMetadata)
    }
    
}
