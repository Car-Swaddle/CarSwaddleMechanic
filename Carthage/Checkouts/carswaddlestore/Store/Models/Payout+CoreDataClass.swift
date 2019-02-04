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
    status: Payout.Status,
    method: String,
    sourceType: String,
    statementDescriptor: String?,
    failureMessage: String?,
    failureCode: String?,
    failureBalanceTransaction: String?,
    balanceTransactionID: String?
)


@objc(Payout)
final public class Payout: NSManagedObject, JSONInitable, NSManagedObjectFetchable {
    
    
    @NSManaged private var primitiveStatus: String
    
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
    
    public enum Status: String {
        case inTransit = "in_transit"
        case paid
        case pending
        case canceled
        case failed
        
        public var localizedString: String {
            switch self {
            case .inTransit:
                return NSLocalizedString("In transit", comment: "Localized string for payout status")
            case .paid:
                return NSLocalizedString("Paid", comment: "Localized string for payout status")
            case .pending:
                return NSLocalizedString("Pending", comment: "Localized string for payout status")
            case .canceled:
                return NSLocalizedString("Canceled", comment: "Localized string for payout status")
            case .failed:
                return NSLocalizedString("Failed", comment: "Localized string for payout status")
            }
        }
        
    }
    
    public static var arrivalDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Payout.arrivalDate), ascending: false)
    }
    
    public static var currentMechanicPredicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Payout.mechanic.identifier), Mechanic.currentMechanicID ?? "")
    }
    
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
            let status = Status(rawValue: json["status"] as? String ?? ""),
            let method = json["method"] as? String,
            let payoutDescription = json["description"] as? String,
            let sourceType = json["source_type"] as? String else { return nil }
        
        let destination = json["destination"] as? String
        let statementDescriptor = json["statement_descriptor"] as? String
        let failureMessage = json["failure_message"] as? String
        let failureCode = json["failure_code"] as? String
        let failureBalanceTransaction = json["failure_balance_transaction"] as? String
        
        let balanceTransactionID = json["balance_transaction"] as? String
        
        let arrivalDate = Date(timeIntervalSince1970: TimeInterval(arrivalInt))
        let createdDate = Date(timeIntervalSince1970: TimeInterval(createdInt))
        
        return (identifier: identifier, amount: amount, arrivalDate: arrivalDate, created: createdDate, currency: currency, payoutDescription: payoutDescription, destination: destination, type: type, status: status, method: method, sourceType: sourceType, statementDescriptor: statementDescriptor, failureMessage: failureMessage, failureCode: failureCode, failureBalanceTransaction: failureBalanceTransaction, balanceTransactionID)
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
        balanceTransactionID = values.balanceTransactionID
    }
    
}

public extension Payout {
    
    public static func sumOfPayoutAmount(with status: Payout.Status, in context: NSManagedObjectContext) -> Int? {
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: Payout.entityName)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = Payout.predicate(for: [.inTransit, .pending])
        
        let expressionName = "sumOfNet"
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = expressionName
        expressionDescription.expression = NSExpression(forKeyPath: #keyPath(Payout.amount))
        expressionDescription.expressionResultType = NSAttributeType.decimalAttributeType
        
        fetchRequest.propertiesToFetch = [expressionDescription]
        
        do {
            let result = try context.fetch(fetchRequest)
            if let first = result.first as? [String: Any] {
                return first[expressionName] as? Int
            }
            return nil
        } catch {
            print(error)
            return nil
        }
    }
    
    public static func fetchPayoutsInTransitOrPending(in context: NSManagedObjectContext) -> [Payout] {
        return fetchPayouts(with: [.inTransit, .pending], in: context)
    }
    
    public static func fetchPayouts(with status: [Status], in context: NSManagedObjectContext) -> [Payout] {
        let fetchRequest: NSFetchRequest<Payout> = Payout.fetchRequest()
        fetchRequest.sortDescriptors = [Payout.arrivalDateSortDescriptor]
        fetchRequest.predicate = Payout.predicate(for: status)
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    public static func predicate(for status: [Status]) -> NSPredicate {
        return NSPredicate(format: "status in %@", status.map { $0.rawValue } )
    }
    
    public static func purgeAll(in context: NSManagedObjectContext) {
        let allPayouts = Payout.fetchAllObjects(with: [Payout.arrivalDateSortDescriptor], in: context)
        for payout in allPayouts {
            context.delete(payout)
        }
    }
    
}
