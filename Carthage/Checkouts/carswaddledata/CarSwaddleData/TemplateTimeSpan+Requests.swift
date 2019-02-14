//
//  TemplateTimeSpan+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 10/23/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Store
import CarSwaddleNetworkRequest
import CoreData


public final class TemplateTimeSpanNetwork: Network {
    
    private var availabilityService: AvailabilityService
    
    override public init(serviceRequest: Request) {
        self.availabilityService = AvailabilityService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getTimeSpans(ofMechanicWithID mechanicID: String? = nil, in context: NSManagedObjectContext, completion: @escaping (_ timeSpans: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return availabilityService.getAvailability(ofMechanicWithID: mechanicID) { jsonArray, error in
            context.performOnImportQueue {
                var timeSpanObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(timeSpanObjectIDs, error)
                    }
                }
                
                let mechanic: Mechanic?
                if let mechanicID = mechanicID {
                    mechanic = Mechanic.fetch(with: mechanicID, in: context)
                } else {
                    mechanic = Mechanic.currentLoggedInMechanic(in: context)
                }
                var previousTimeSpans = mechanic?.scheduleTimeSpans
                
                for json in jsonArray ?? [] {
                    guard let span = TemplateTimeSpan.fetchOrCreate(json: json, context: context) else { continue }
                    if span.objectID.isTemporaryID {
                        (try? context.obtainPermanentIDs(for: [span]))
                    }
                    previousTimeSpans?.remove(span)
                    timeSpanObjectIDs.append(span.objectID)
                }
                
                for timeSpan in previousTimeSpans ?? [] {
                    context.delete(timeSpan)
                }
                
                context.persist()
            }
        }
    }
    
    @discardableResult
    public func postTimeSpans(templateTimeSpans: [TemplateTimeSpan], in context: NSManagedObjectContext, completion: @escaping (_ timeSpans: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        
        var jsonArray: [JSONObject] = []
        for timeSpan in templateTimeSpans {
            jsonArray.append(timeSpan.toJSON)
        }
        
        return availabilityService.postAvailability(jsonArray: jsonArray) { jsonArray, error in
            context.performOnImportQueue {
                var timeSpanObjectIDs: [NSManagedObjectID] = []
                defer {
                    DispatchQueue.global().async {
                        completion(timeSpanObjectIDs, error)
                    }
                }
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                var previousTimeSpans = mechanic?.scheduleTimeSpans
                
                for json in jsonArray ?? [] {
                    guard let span = TemplateTimeSpan.fetchOrCreate(json: json, context: context) else { continue }
                    if span.objectID.isTemporaryID {
                        (try? context.obtainPermanentIDs(for: [span]))
                    }
                    previousTimeSpans?.remove(span)
                    timeSpanObjectIDs.append(span.objectID)
                }
                
                for timeSpan in previousTimeSpans ?? [] {
                    context.delete(timeSpan)
                }
                
                context.persist()
            }
        }
    }
    
}

