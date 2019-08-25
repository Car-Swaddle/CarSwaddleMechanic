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
    private var fileService: FileService
    
    override public init(serviceRequest: Request) {
        self.stripeService = StripeService(serviceRequest: serviceRequest)
        self.fileService = FileService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func updateCurrentUserVerification(in context: NSManagedObjectContext, completion: @escaping (_ verificationObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getVerification { json, error in
            var verificationObjectID: NSManagedObjectID?
            defer {
                completion(verificationObjectID, error)
            }
            guard let json = json else { return }
            
            let currentMechanic = Mechanic.currentLoggedInMechanic(in: context)
            
            if let previousVerification = currentMechanic?.verification {
                context.delete(previousVerification)
            }
            
            let verification = Verification(json: json, context: context)
            verification.mechanic = currentMechanic
            context.persist()
            verificationObjectID = verification.objectID
        }
    }
    
    @discardableResult
    public func requestBalance(in context: NSManagedObjectContext, completion: @escaping (_ balanceObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getBalance { json, error in
            context.performOnImportQueue {
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
    public func requestTransactionDetails(transactionID: String, in context: NSManagedObjectContext, completion: @escaping (_ transactionObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getTransactionDetails(transactionID: transactionID) { [weak self] json, error in
            self?.finishTransactionDetails(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func updateTransactionDetails(transactionID: String, mechanicCostCents: Int?, drivingDistanceMiles: Int?, in context: NSManagedObjectContext, completion: @escaping (_ transactionObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.updateTransactionDetails(transactionID: transactionID, mechanicCostCents: mechanicCostCents, drivingDistanceMiles: drivingDistanceMiles) { [weak self] json, error in
            self?.finishTransactionDetails(json: json, error: error, in: context, completion: completion)
        }
    }
    
    @discardableResult
    public func updateTransactionDetails(transactionID: String, mechanicCostCents: Int?, drivingDistanceMeters: Int?, in context: NSManagedObjectContext, completion: @escaping (_ transactionObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.updateTransactionDetails(transactionID: transactionID, mechanicCostCents: mechanicCostCents, drivingDistanceMeters: drivingDistanceMeters) { [weak self] json, error in
            self?.finishTransactionDetails(json: json, error: error, in: context, completion: completion)
        }
    }
    
    private func finishTransactionDetails(json: JSONObject?, error: Error?, in context: NSManagedObjectContext, completion: @escaping (_ transactionObjectID: NSManagedObjectID?, _ error: Error?) -> Void) {
        context.performOnImportQueue {
            var transactionObjectID: NSManagedObjectID?
            defer {
                DispatchQueue.global().async {
                    completion(transactionObjectID, error)
                }
            }
            guard let json = json else { return }
            let transaction = Transaction.fetchOrCreate(json: json, context: context)
            context.persist()
            transactionObjectID = transaction?.objectID
        }
    }
    
    @discardableResult
    public func uploadTransactionReceipt(transactionID: String, fileURL: URL, in context: NSManagedObjectContext, completion: @escaping (_ transactionReceiptObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let uuid = UUID().uuidString
        _ = try? profileImageStore.storeFile(at: fileURL, fileName: uuid)
        return fileService.uploadTransactionReceipt(transactionID: transactionID, fileURL: fileURL) { json, error in
            context.performOnImportQueue {
                var receiptObjectID: NSManagedObjectID?
                defer {
                    DispatchQueue.global().async {
                        completion(receiptObjectID, error)
                    }
                }
                guard let json = json else { return }
                let receipt = TransactionReceipt.fetchOrCreate(json: json, context: context)
                if receipt?.transactionMetadata == nil,
                    let metadata = Transaction.fetch(with: transactionID, in: context)?.transactionMetadata {
                    receipt?.transactionMetadata = metadata
                }
                if let imageData = profileImageStore.getImage(withName: uuid)?.pngData() {
                    _ = try? profileImageStore.storeFile(data: imageData, fileName: (json["receiptPhotoID"] as? String) ?? uuid)
                }
                
                context.persist()
                receiptObjectID = receipt?.objectID
            }
        }
    }
    
    @discardableResult
    public func requestTransactions(startingAfterID: String? = nil, payoutID: String? = nil, limit: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ lastID: String?, _ hasMore: Bool, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getTransactions(startingAfterID: startingAfterID, payoutID: payoutID, limit: limit) { json, error in
            context.performOnImportQueue {
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
                    
                    if let payout = payout {
                        transaction.payout = payout
                    }
                    
                    objectIDs.append(transaction.objectID)
                    lastID = transaction.identifier
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func requestPayouts(startingAfterID: String? = nil, status: Payout.Status? = nil, limit: Int? = nil, in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ lastID: String?, _ hasMore: Bool, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getPayouts(startingAfterID: startingAfterID, status: status?.rawValue, limit: limit) { json, error in
            context.performOnImportQueue {
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
    
    @discardableResult
    public func requestPayoutsPending(in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return requestPayouts(status: .pending, limit: 300, in: context) { objectIDs, lastID, hasMore, error in
            completion(objectIDs, error)
        }
    }
    
    @discardableResult
    public func requestPayoutsInTransit(in context: NSManagedObjectContext, completion: @escaping (_ transactionIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return requestPayouts(status: .inTransit, limit: 300, in: context) { objectIDs, lastID, hasMore, error in
            completion(objectIDs, error)
        }
    }
    
    @discardableResult
    public func requestBankAccount(in context: NSManagedObjectContext, completion: @escaping (_ bankAccountObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return stripeService.getBankAccount { json, error in
            context.performOnImportQueue {
                var objectID: NSManagedObjectID?
                defer {
                    completion(objectID, error)
                }
                guard let json = json else { return }
                
                guard let bankAccount = BankAccount.fetchOrCreate(json: json, context: context) else { return }
                context.persist()
                objectID = bankAccount.objectID
            }
        }
    }
    
}
