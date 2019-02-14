//
//  Review+Requests.swift
//  CarSwaddleData
//
//  Created by Kyle Kendall on 1/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CoreData
import Store
import CarSwaddleNetworkRequest


public final class ReviewNetwork: Network {
    
    private var reviewService: ReviewService
    
    override public init(serviceRequest: Request) {
        self.reviewService = ReviewService(serviceRequest: serviceRequest)
        super.init(serviceRequest: serviceRequest)
    }
    
    @discardableResult
    public func getReviewsByCurrentUser(limit: Int = 100, offset: Int = 0, in context: NSManagedObjectContext, completion: @escaping (_ reviewsObjectID: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return reviewService.getReviewsByCurrentUser(limit: limit, offset: offset) { [weak self] json, error in
            self?.completeReview(jsonKey: "reviewsGivenByCurrentUser", in: context, json: json, error: error, completion: completion)
        }
    }
    
    @discardableResult
    public func getReviews(forMechanicWithID mechanicID: String, limit: Int = 100, offset: Int = 0, in context: NSManagedObjectContext, completion: @escaping (_ reviewsObjectID: [NSManagedObjectID], _ error: Error?) -> Void) -> URLSessionDataTask? {
        return reviewService.getReviews(forMechanicWithID: mechanicID, limit: limit, offset: offset) { [weak self] json, error in
            self?.completeReview(jsonKey: "reviewsGivenToMechanic", in: context, json: json, error: error, completion: completion)
        }
    }
    
    private func completeReview(jsonKey: String, in context: NSManagedObjectContext, json: JSONObject?, error: Error?, completion: @escaping (_ reviewsObjectID: [NSManagedObjectID], _ error: Error?) -> Void) {
        context.performOnImportQueue {
            var reviewIDs: [NSManagedObjectID] = []
            defer {
                DispatchQueue.global().async {
                    completion(reviewIDs, error)
                }
            }
            guard let json = json,
                let jsonArray = json[jsonKey] as? [JSONObject] else { return }
            
            for json in jsonArray {
                guard let review = Review.fetchOrCreate(json: json, context: context) else { continue }
                if review.objectID.isTemporaryID {
                    (try? context.obtainPermanentIDs(for: [review]))
                }
                reviewIDs.append(review.objectID)
            }
            
            context.persist()
        }
    }
    
    
//    @discardableResult
//    public func getAverageRatingForCurrentUser(completion: @escaping (_ rating: CGFloat) -> Void) -> URLSessionDataTask? {
//
////        return getRatingsReceived(queryItems: [:], completion: completion)
//    }
//
//    @discardableResult
//    public func getAverageRating(userID: String, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
//        return getRatingsReceived(queryItems: ["user": userID], completion: completion)
//    }
//
//    @discardableResult
//    public func getAverageRating(mechanicID: String, completion: @escaping (averageRating:) -> Void) -> URLSessionDataTask? {
//
////        return getRatingsReceived(queryItems: ["mechanic": mechanicID], completion: completion)
//    }
//
//    private func getAverageRating() {
//
//    }
    
}

