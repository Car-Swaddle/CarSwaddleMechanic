//
//  Review+CoreDataClass.swift
//  Store
//
//  Created by Kyle Kendall on 1/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//
//

import Foundation
import CoreData


typealias ReviewValues = (identifier: String, rating: CGFloat, text: String?, reviewerID: String, revieweeID: String, mechanicID: String?, userID: String?, autoServiceIDFromUser: String?, autoServiceIDFromMechanic: String?, creationDate: Date)

@objc(Review)
final public class Review: NSManagedObject, NSManagedObjectFetchable, JSONInitable {
    
    public convenience init?(json: JSONObject, context: NSManagedObjectContext) {
        guard let values = Review.values(from: json) else { return nil }
        self.init(context: context)
        configure(with: values, in: context)
    }
    
    public func configure(with json: JSONObject) throws {
        guard let values = Review.values(from: json) else { throw StoreError.invalidJSON }
        guard let context = managedObjectContext else { return }
        self.configure(with: values, in: context)
    }
    
    static private func values(from json: JSONObject) -> ReviewValues? {
        guard let identifier = json["id"] as? String,
            let reviewerID = json["reviewerID"] as? String,
            let revieweeID = json["revieweeID"] as? String,
            let rating = json["rating"] as? CGFloat,
            let creationDateString = json["createdAt"] as? String,
            let creationDate = serverDateFormatter.date(from: creationDateString) else { return nil }
        
        let text = json["text"] as? String
        
        let mechanicID = json["mechanicID"] as? String ?? (json["mechanic"] as? JSONObject)?["id"] as? String
        let userID = json["userID"] as? String ?? (json["user"] as? JSONObject)?["id"] as? String
        let autoServiceIDFromMechanic = json["autoServiceIDFromMechanic"] as? String
        let autoServiceIDFromUser = json["autoServiceIDFromUser"] as? String
        
        return (identifier, rating, text, reviewerID, revieweeID, mechanicID, userID, autoServiceIDFromMechanic, autoServiceIDFromUser, creationDate)
    }
    
    private func configure(with values: ReviewValues, in context: NSManagedObjectContext) {
        self.identifier = values.identifier
        self.rating = values.rating
        self.text = values.text
        self.reviewerID = values.reviewerID
        self.revieweeID = values.revieweeID
        self.creationDate = values.creationDate
        
        if let mechanicID = values.mechanicID {
            self.mechanic = Mechanic.fetch(with: mechanicID, in: context)
        }
        if let userID = values.userID {
            self.user = User.fetch(with: userID, in: context)
        }
        if let autoServiceIDFromMechanic = values.autoServiceIDFromMechanic {
            self.autoServiceFromMechanic = AutoService.fetch(with: autoServiceIDFromMechanic, in: context)
        }
        if let autoServiceIDFromUser = values.autoServiceIDFromUser {
            self.autoServiceFromUser = AutoService.fetch(with: autoServiceIDFromUser, in: context)
        }
    }
    
    public static var creationDateSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Review.creationDate), ascending: false)
    }
    
    public static func predicateForCurrentMechanic() -> NSPredicate? {
        guard let mechanicID = Mechanic.currentMechanicID else { return nil }
        return Review.predicate(for: mechanicID)
    }
    
    public static func predicate(for mechanicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Review.revieweeID), mechanicID)
    }
    
}
