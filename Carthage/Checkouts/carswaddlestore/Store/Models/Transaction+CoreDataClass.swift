//
//  Transaction+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias TransactionValues = (identifier: String, amount: Int, availableOn: Date, created: Date, currency: String, transactionDescription: String?, exchangeRate: NSNumber?, fee: Int, net: Int, source: String, status: String, type: String)

@objc(Transaction)
final public class Transaction: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    @NSManaged private var primitiveStatus: String
    
    public enum Status: String {
        case pending
        case available
        
        public var localizedString: String {
            switch self {
            case .pending:
                return NSLocalizedString("Pending", comment: "Status of a transaction")
            case .available:
                return NSLocalizedString("Available", comment: "Status of a transaction")
            }
        }
        
    }
    
    
    private let statusKey = "status"
    public var status: Status {
        get {
            willAccessValue(forKey: statusKey)
            guard let status = Status(rawValue: primitiveStatus) else { return .pending }
            didAccessValue(forKey: statusKey)
            return status
        }
        set {
            willChangeValue(forKey: statusKey)
            primitiveStatus = newValue.rawValue
            didChangeValue(forKey: statusKey)
        }
    }
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Transaction.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Transaction.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, in: context)
    }
    
    static private func values(from json: JSONObject) -> TransactionValues? {
        guard let identifier = json["id"] as? String,
            let amount = json["amount"] as? Int,
            let availableOnInt = json["available_on"] as? Int,
            let createdInt = json["created"] as? Int,
            let currency = json["currency"] as? String,
            let fee = json["fee"] as? Int,
            let net = json["net"] as? Int,
            let source = json["source"] as? String,
            let status = json["status"] as? String,
            let type = json["type"] as? String else { return nil }
        
        let avilableOnDate = Date(timeIntervalSince1970: TimeInterval(availableOnInt))
        let createdDate = Date(timeIntervalSince1970: TimeInterval(createdInt))
        
        let transactionDescription = json["transaction_description"] as? String
        
        var exchangeRateNumber: NSNumber?
        if let exchangeRateFloat = json["exchange_rate"] as? Float {
            exchangeRateNumber = NSNumber(value: exchangeRateFloat)
        }
        
        return (identifier, amount, avilableOnDate, createdDate, currency, transactionDescription, exchangeRateNumber, fee, net, source, status, type)
    }
    
    private func configure(with values: TransactionValues, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.amount = values.amount
        self.availableOn = values.availableOn
        self.created = values.created
        self.currency = values.currency
        self.fee = values.fee
        self.net = values.net
        self.source = values.source
        self.status = Status(rawValue: values.status) ?? .pending
        self.type = values.type
        self.transactionDescription = values.transactionDescription
        self.exchangeRate = values.exchangeRate
    }
    
    public static var createdSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Transaction.created), ascending: false)
    }
    
    public static var currentMechanicPredicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Transaction.mechanic.identifier), Mechanic.currentMechanicID ?? "")
    }
    
    public static func predicate(forPayoutID payoutID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Transaction.payout.identifier), payoutID)
    }
    
    public static func predicateExcluding(identifier: String) -> NSPredicate {
        return NSPredicate(format: "%K != %@", #keyPath(Transaction.identifier), identifier)
    }
    
}
