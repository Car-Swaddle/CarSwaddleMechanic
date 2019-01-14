//
//  Stripe+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreLocation
import CoreData

final public class StripeNetwork: Network {
    
    private var stripeService: StripeService
    
    override public init(serviceRequest: Request) {
        self.stripeService = StripeService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func requestVerification(completion: @escaping (_ verification: Verification?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getVerification { json, error in
            var verification: Verification?
            defer {
                completion(verification, error)
            }
            guard let json = json else { return }
            verification = Verification(json: json)
        }
    }
    
    @discardableResult
    public func requestBalance(in context: NSManagedObjectContext, completion: @escaping (_ balanceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getBalance { json, error in
            context.perform {
                var objectID: NSManagedObjectID?
                defer {
                    completion(objectID, error)
                }
                guard let json = json else { return }
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                
                if let previous = mechanic?.balance {
                    context.delete(previous)
                }
                
                guard let balance = Balance(json: json, context: context) else { return }
                mechanic?.balance = balance
                context.persist()
                objectID = balance.objectID
            }
        }
    }
    
    @discardableResult
    public func requestTransaction(startingAfterID: String? = nil, payoutID: String? = nil, limit: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ lastID: String?, _ hasMore: Bool, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getTransactions(startingAfterID: startingAfterID, payoutID: payoutID, limit: limit) { json, error in
            context.perform {
                var objectIDs: [NSManagedObjectID] = []
                var lastID: String?
                var hasMore: Bool = false
                defer {
                    completion(objectIDs, lastID, hasMore, error)
                }
                guard let json = json else { return }
                
                hasMore = (json["has_more"] as? Bool) ?? false
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                var payout: Payout?
                if let payoutID = payoutID, let fetchedPayout = Payout.fetch(with: payoutID, in: context) {
                    payout = fetchedPayout
                }
                for transactionJSON in json["data"] as? [JSONObject] ?? [] {
                    guard let transaction = Transaction.fetchOrCreate(json: transactionJSON, context: context) else { continue }
                    transaction.mechanic = mechanic
                    if transaction.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [transaction])
                    }
                    
                    transaction.payout = payout
                    
                    objectIDs.append(transaction.objectID)
                    lastID = transaction.identifier
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func requestPayouts(startingAfterID: String? = nil, limit: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ lastID: String?, _ hasMore: Bool, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getPayouts(startingAfterID: startingAfterID, limit: limit) { json, error in
            context.perform {
                var objectIDs: [NSManagedObjectID] = []
                var lastID: String?
                var hasMore: Bool = false
                defer {
                    completion(objectIDs, lastID, hasMore, error)
                }
                guard let json = json else { return }
                
                hasMore = (json["has_more"] as? Bool) ?? false
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                for payoutJSON in json["data"] as? [JSONObject] ?? [] {
                    guard let payout = Payout.fetchOrCreate(json: payoutJSON, context: context) else { continue }
                    payout.mechanic = mechanic
                    if payout.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [payout])
                    }
                    objectIDs.append(payout.objectID)
                    lastID = payout.identifier
                }
                context.persist()
            }
        }
    }
    
}


public class Verification {
    
    init(json: JSONObject) {
        self.disabledReason = json["disabled_reason"] as? String
        if let dueByDate = json["due_by"] as? Double {
            self.dueByDate = Date.init(timeIntervalSince1970: dueByDate)
        }
        let fieldsNeededStrings = json["fields_needed"] as? [String] ?? []
        var fieldsNeeded: [Field] = []
        for fieldString in fieldsNeededStrings {
            guard let field = Field(rawValue: fieldString) else { continue }
            fieldsNeeded.append(field)
        }
        self.fieldsNeeded = fieldsNeeded
    }
    
    /// The reason the account is disabled
    public var disabledReason: String?
    /// The date by which the fields needed are due
    public var dueByDate: Date?
    /// The fields needed before the user can get funds
    public var fieldsNeeded: [Field]
    
    public enum Field: String {
        /// The bank account used to transfer funds i.e. payout
        case externalAccount = "external_account"
        /// The city of the entity's address
        case addressCity = "legal_entity.address.city"
        /// The first line of the entity's address
        case addressLine1 = "legal_entity.address.line1"
        /// The postal code of the entity's address
        case addressPostalCode = "legal_entity.address.postal_code"
        /// The state of the entity's address
        case addressState = "legal_entity.address.state"
        /// The name of the business (only if type is company)
        case businessName = "legal_entity.business_name"
        /// The business tax ID of the business (only if type is company)
        case businessTaxID = "legal_entity.business_tax_id"
        /// The day of the month of the representative's/user's birth
        case birthdayDay = "legal_entity.dob.day"
        /// The month of the representative's/user's birth
        case birthdayMonth = "legal_entity.dob.month"
        /// The year of the representative's/user's birth
        case birthdayYear = "legal_entity.dob.year"
        /// The representative's/user's first name
        case firstName = "legal_entity.first_name"
        /// The representative's/user's last name
        case lastName = "legal_entity.last_name"
        /// The last 4 digits of the representative's/user's social security number
        case socialSecurityNumberLast4Digits = "legal_entity.ssn_last_4"
        /// The legal entity type (individual or company)
        case type = "legal_entity.type"
        /// The date the user accepted terms of service
        case termsOfServiceAcceptanceDate = "tos_acceptance.date"
        /// The IP address used when accepting terms of service
        case termsOfServiceIPAddress = "tos_acceptance.ip"
        /// Full Social Security Number
        case personalIDNumber = "legal_entity.personal_id_number"
        /// The document (passport or drivers license)
        case verificationDocument = "legal_entity.verification.document"
    }
    
}


