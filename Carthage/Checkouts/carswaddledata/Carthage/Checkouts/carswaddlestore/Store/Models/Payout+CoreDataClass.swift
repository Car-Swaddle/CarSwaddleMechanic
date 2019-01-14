//
//  Payout+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/13/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias PayoutValues = (
    identifier: String,
    amount: Int,
    arrivalDate: Date,
    created: Date,
    currency: String,
    payoutDescription: String,
    destination: String?,
    type: String,
    status: String,
    method: String,
    sourceType: String,
    statementDescriptor: String?,
    failureMessage: String?,
    failureCode: String?,
    failureBalanceTransaction: String?
)


@objc(Payout)
final public class Payout: NSManagedObject, JSONInitable, NSManagedObjectFetchable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Payout.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Payout.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, in: context)
    }
    
    static private func values(from json: JSONObject) -> PayoutValues? {
        guard let identifier = json["id"] as? String,
            let amount = json["amount"] as? Int,
            let arrivalInt = json["arrival_date"] as? Int,
            let createdInt = json["created"] as? Int,
            let currency = json["currency"] as? String,
            let type = json["type"] as? String,
            let status = json["status"] as? String,
            let method = json["method"] as? String,
            let payoutDescription = json["description"] as? String,
            let sourceType = json["source_type"] as? String else { return nil }
        
        let destination = json["destination"] as? String
        let statementDescriptor = json["statement_descriptor"] as? String
        let failureMessage = json["failure_message"] as? String
        let failureCode = json["failure_code"] as? String
        let failureBalanceTransaction = json["failure_balance_transaction"] as? String
        
        let arrivalDate = Date(timeIntervalSince1970: TimeInterval(arrivalInt))
        let createdDate = Date(timeIntervalSince1970: TimeInterval(createdInt))
        
        return (identifier: identifier, amount: amount, arrivalDate: arrivalDate, created: createdDate, currency: currency, payoutDescription: payoutDescription, destination: destination, type: type, status: status, method: method, sourceType: sourceType, statementDescriptor: statementDescriptor, failureMessage: failureMessage, failureCode: failureCode, failureBalanceTransaction: failureBalanceTransaction)
    }
    
    private func configure(with values: PayoutValues, in context: NSManagedObjectContext) {
        identifier = values.identifier
        amount = values.amount
        arrivalDate = values.arrivalDate
        created = values.created
        currency = values.currency
        payoutDescription = values.payoutDescription
        destination = values.destination
        type = values.type
        status = values.status
        method = values.method
        sourceType = values.sourceType
        statementDescriptor = values.statementDescriptor
        failureMessage = values.failureMessage
        failureCode = values.failureCode
        failureBalanceTransaction = values.failureBalanceTransaction
    }
    
}
