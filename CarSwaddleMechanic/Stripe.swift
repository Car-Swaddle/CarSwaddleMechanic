//
//  Stripe.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/29/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation
import Stripe
import CarSwaddleNetworkRequest
import CarSwaddleUI

private let stripeLivePublishableKey = "pk_live_ZJkoNBROBK0ttmZLDNfNF0Cw00VwQ7JjFw"
private let stripeTestPublishableKey = "pk_test_93FPMcPQ4mSaWfjtMWlkGvDr00ytb8KnDJ"

public var stripePublishableKey: String {
    guard let serverType = Tweak.currentDomainServerType() else { return stripeTestPublishableKey }
    switch serverType {
    case .local: return stripeTestPublishableKey
    case .staging: return stripeTestPublishableKey
    case .production: return stripeLivePublishableKey
    }
}
public let appleMerchantIdentifier: String = "merchant.com.carswaddle"


let stripe = StripeClient()

final class StripeClient: NSObject, STPCustomerEphemeralKeyProvider {
    
    private let stripeService = StripeService(serviceRequest: serviceRequest)
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        stripeService.getKeys(apiVersion: apiVersion) { json, error in
            completion(json, error)
        }
    }
    
}
