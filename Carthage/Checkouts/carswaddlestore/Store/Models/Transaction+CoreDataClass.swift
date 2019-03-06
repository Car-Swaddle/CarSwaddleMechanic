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
    @NSManaged private var primitiveAvailableOn: Date
    @NSManaged private var primitiveAdjustedAvailableOnDate: Date
    
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
    
    public var transactionType: TransactionType {
        return TransactionType(rawValue: type)!
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
    
    private let availableOnKey = "availableOn"
    public var availableOn: Date {
        get {
            willAccessValue(forKey: availableOnKey)
            let availableOn = primitiveAvailableOn
            didAccessValue(forKey: availableOnKey)
            return availableOn
        }
        set {
            willChangeValue(forKey: availableOnKey)
            primitiveAvailableOn = newValue
            didChangeValue(forKey: availableOnKey)
            
            if let adjustedDate = Calendar.current.date(bySetting: .hour, value: 0, of: newValue) {
                willChangeValue(forKey: availableOnKey)
                primitiveAdjustedAvailableOnDate = adjustedDate
                didChangeValue(forKey: availableOnKey)
            }
        }
    }
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Transaction.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Transaction.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, json: json, in: context)
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
        
        /*
         "id": "txn_1E90e6Kvdbv2b5urs849LQ8S",
         "object": "balance_transaction",
         "amount": -5931,
         "available_on": 1552003200,
         "created": 1551405522,
         "currency": "usd",
         "description": "REFUND FOR PAYMENT",
         "exchange_rate": null,
         "fee": 0,
         "fee_details": [],
         "net": -5931,
         "source": "pyr_1E90e6Kvdbv2b5urg3UzJoii",
         "status": "pending",
         "type": "payment_refund"
         */
        
        let transactionDescription = json["description"] as? String
        
        var exchangeRateNumber: NSNumber?
        if let exchangeRateFloat = json["exchange_rate"] as? Float {
            exchangeRateNumber = NSNumber(value: exchangeRateFloat)
        }
        
        return (identifier, amount, avilableOnDate, createdDate, currency, transactionDescription, exchangeRateNumber, fee, net, source, status, type)
    }
    
    private func configure(with values: TransactionValues, json: JSONObject, in context: NSManagedObjectContext) {
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
        
        if let metadataJSON = json["car_swaddle_meta"] as? JSONObject {
            self.transactionMetadata = TransactionMetadata.fetchOrCreate(json: metadataJSON, context: context)
        }
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
    
    public static var transactionListPredicate: NSPredicate {
        return Transaction.predicate(excluding: [.payout])
    }
    
    public static func predicate(excluding transactionTypes: [Transaction.TransactionType]) -> NSPredicate {
        let types = transactionTypes.map { $0.rawValue }
        return NSPredicate(format: "%K NOT in %@", #keyPath(Transaction.type), types)
    }
    
    public static func predicate(with transactionTypes: [Transaction.TransactionType]) -> NSPredicate {
        let types = transactionTypes.map { $0.rawValue }
        return NSPredicate(format: "%K in %@", #keyPath(Transaction.type), types)
    }
    
}



/*
 type can be: adjustment, advance, advance_funding, application_fee, application_fee_refund, charge, connect_collection_transfer, issuing_authorization_hold, issuing_authorization_release, issuing_transaction, payment, payment_failure_refund, payment_refund, payout, payout_cancel, payout_failure, refund, refund_failure, reserve_transaction, reserved_funds, stripe_fee, stripe_fx_fee, tax_fee, topup, topup_reversal, transfer, transfer_cancel, transfer_failure, or transfer_refund
 */


extension Transaction {
    
    public enum TransactionType: String {
        case adjustment = "adjustment"
        case advance = "advance"
        case advanceFunding = "advance_funding"
        case applicationFee = "application_fee"
        case applicationFeeRefund = "application_fee_refund"
        case charge = "charge"
        case connectCollectionTransfer = "connect_collection_transfer"
        case issuingAuthorizationHold = "issuing_authorization_hold"
        case issuingAuthorizationRelease = "issuing_authorization_release"
        case issuingTransaction = "issuing_transaction"
        case payment = "payment"
        case paymentFailureRefund = "payment_failure_refund"
        case paymentRefund = "payment_refund"
        case payout = "payout"
        case payoutCancel = "payout_cancel"
        case payoutFailure = "payout_failure"
        case refund = "refund"
        case refundFailure = "refund_failure"
        case reserveTransaction = "reserve_transaction"
        case reservedFunds = "reserved_funds"
        case stripeFee = "stripe_fee"
        case stripeFxFee = "stripe_fx_fee"
        case taxFee = "tax_fee"
        case topup = "topup"
        case topupReversal = "topup_reversal"
        case transfer = "transfer"
        case transferCancel = "transfer_cancel"
        case transferFailure = "transfer_failure"
        case transferRefund = "transfer_refund"
    }
    
}
