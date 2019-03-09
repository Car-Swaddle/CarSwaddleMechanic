//
//  BankAccount+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 3/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData

typealias BankAccountValues = (identifier: String, accountID: String, accountHolderName: String, accountHolderType: String, bankName: String, country: String, defaultForCurrency: Bool, currency: String, fingerprint: String, last4: String, routingNumber: String, status: String)

@objc(BankAccount)
final public class BankAccount: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = BankAccount.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, json: json, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = BankAccount.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, json: json, in: context)
    }
    
    static private func values(from json: JSONObject) -> BankAccountValues? {
        guard let identifier = json["id"] as? String,
            let accountID = json["account"] as? String,
            let accountHolderName = json["account_holder_name"] as? String,
            let accountHolderType = json["account_holder_type"] as? String,
            let bankName = json["bank_name"] as? String,
            let country = json["country"] as? String,
            let defaultForCurrency = json["default_for_currency"] as? Bool,
            let fingerprint = json["fingerprint"] as? String,
            let last4 = json["last4"] as? String,
            let routingNumber = json["routing_number"] as? String,
            let status = json["status"] as? String,
            let currency = json["currency"] as? String else { return nil }
        
        return (identifier, accountID, accountHolderName, accountHolderType, bankName, country, defaultForCurrency, currency, fingerprint, last4, routingNumber, status)
    }
    
    private func configure(with values: BankAccountValues, json: JSONObject, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.accountID = values.accountID
        self.accountHolderName = values.accountHolderName
        self.accountHolderType = values.accountHolderType
        self.bankName = values.bankName
        self.country = values.country
        self.defaultForCurrency = values.defaultForCurrency
        self.currency = values.currency
        self.fingerprint = values.fingerprint
        self.last4 = values.last4
        self.routingNumber = values.routingNumber
        self.status = values.status
        
        self.mechanic = Mechanic.currentLoggedInMechanic(in: context)
    }
    
}
