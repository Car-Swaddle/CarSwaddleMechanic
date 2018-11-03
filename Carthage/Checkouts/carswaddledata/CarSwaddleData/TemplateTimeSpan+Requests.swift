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


public class TemplateTimeSpanNetwork {
    
    public let serviceRequest: Request
    
    public init(serviceRequest: Request) {
        self.serviceRequest = serviceRequest
    }
    
    private lazy var availabilityService = AvailabilityService(serviceRequest: serviceRequest)
    
    @discardableResult
    public func getTimeSpans(in context: NSManagedObjectContext, completion: @escaping (_ timeSpans: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return availabilityService.getAvailability { jsonArray, error in
            context.perform {
                var timeSpans: [NSManagedObjectID] = []
                defer {
                    completion(timeSpans, error)
                }
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                mechanic?.deleteAllCurrentScheduleTimeSpans()
                
                for json in jsonArray ?? [] {
                    guard let span = TemplateTimeSpan(json: json, context: context) else { continue }
                    (try? context.obtainPermanentIDs(for: [span]))
                    timeSpans.append(span.objectID)
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
            context.perform {
                var timeSpans: [NSManagedObjectID] = []
                defer {
                    completion(timeSpans, error)
                }
                
                let mechanic = Mechanic.currentLoggedInMechanic(in: context)
                mechanic?.deleteAllCurrentScheduleTimeSpans()
                
                for json in jsonArray ?? [] {
                    guard let span = TemplateTimeSpan(json: json, context: context) else { continue }
                    (try? context.obtainPermanentIDs(for: [span]))
                    timeSpans.append(span.objectID)
                }
                context.persist()
            }
        }
    }
    
}

