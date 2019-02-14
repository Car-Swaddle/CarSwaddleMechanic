//
//  Tax+Request.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 2/10/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//


import Store
import CarSwaddleNetworkRequest
import CoreLocation
import CoreData

final public class TaxNetwork: Network {
    
    private var taxService: TaxService

    override public init(serviceRequest: Request) {
        self.taxService = TaxService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func requestTaxYears(in context: NSManagedObjectContext, completion: @escaping (_ taxInfoObjectIDs: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return taxService.getTaxYears { years, error in
        context.performOnImportQueue {
                var taxInfoObjectIDs: [NSManagedObjectID] = []
                defer {
                    completion(taxInfoObjectIDs, error)
                }
                guard let years = years,
                let mechanic = Mechanic.currentLoggedInMechanic(in: context) else { return }
                for year in years {
                    let taxInfo = TaxInfo.fetchTaxInfo(withYear: year, in: context) ?? TaxInfo(year: year, context: context)
                    taxInfo.mechanic = mechanic
                    if taxInfo.objectID.isTemporaryID == true {
                        try? context.obtainPermanentIDs(for: [taxInfo])
                    }
                    taxInfoObjectIDs.append(taxInfo.objectID)
                }
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func requestTaxInfo(year: String, in context: NSManagedObjectContext, completion: @escaping (_ taxInfoObjectID: NSManagedObjectID?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return taxService.getTaxes(year: year) { json, error in
            context.performOnImportQueue {
                var taxInfoObjectID: NSManagedObjectID?
                defer {
                    completion(taxInfoObjectID, error)
                }
                guard let json = json,
                    let mechanic = Mechanic.currentLoggedInMechanic(in: context) else { return }
                let taxInfo = TaxInfo.fetchOrCreate(with: json, in: context)
                try? taxInfo?.configure(with: json)
                taxInfo?.mechanic = mechanic
                context.persist()
                taxInfoObjectID = taxInfo?.objectID
            }
        }
    }
    
}
