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
        addHairlineView(toSide: .bottom, color: UIColor.gray3)
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
//            Payout.purgeAll(in: privateContext)
            self?.stripeNetwork.requestPayoutsInTransit(in: privateContext) { objectIDs, error in
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
