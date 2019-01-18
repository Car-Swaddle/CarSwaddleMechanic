//
//  EarningsHeaderView.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/12/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store
import CarSwaddleData
import CoreData

final class EarningsHeaderView: UIView, NibInstantiating {
    
    @IBOutlet private weak var balanceAmountViewWrapper: BalanceAmountViewWrapper!
    private var balanceAmountView: BalanceAmountView { return balanceAmountViewWrapper.view }
    
    private var stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureForEmpty()
        if let balance = Mechanic.currentLoggedInMechanic(in: store.mainContext)?.balance {
            configure(with: balance)
        }
    }
    
    private func configure(with balance: Balance) {
        balanceAmountView.configure(with: balance.pending, amountType: .pending)
    }
    
    private func configureForEmpty() {
        balanceAmountView.configureForEmpty()
    }
    
    func updateBalance(completion: @escaping () -> Void = {}) {
        store.privateContext { [weak self] privateContext in
            let group = DispatchGroup()
            group.enter()
            self?.stripeNetwork.requestBalance(in: privateContext) { balanceID, error in
                store.mainContext { mainContext in
                    defer { group.leave() }
                    guard let balanceID = balanceID,
                        let balance = mainContext.object(with: balanceID) as? Balance else { return }
                    self?.configure(with: balance)
                }
            }
            
            group.enter()
            Payout.purgeAll(in: privateContext)
            self?.stripeNetwork.requestPayoutsPendingForBalance(in: privateContext) { objectIDs, error in
                store.mainContext { mainContext in
                    defer { group.leave() }
                    self?.balanceAmountView.inTransitAmount = Payout.sumOfPayoutAmount(with: .inTransit, in: mainContext)
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
    }
    
}

extension Balance {
    
    enum AmountType {
        case pending
        case available
        case reserved
    }
    
}


extension Payout {
    
    static func sumOfPayoutAmount(with status: Payout.Status, in context: NSManagedObjectContext) -> Int? {
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
    
    static func fetchPayoutsInTransitOrPending(in context: NSManagedObjectContext) -> [Payout] {
        return fetchPayouts(with: [.inTransit, .pending], in: context)
    }
    
    static func fetchPayouts(with status: [Status], in context: NSManagedObjectContext) -> [Payout] {
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

