//
//  RemoteNotification.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 8/9/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation
import UIKit

public enum RemoteNotification {
    
    case reminder(reminder: MechanicReminder)
    case mechanicRating(rating: MechanicRating)
    case userDidRate(userDidRate: UserDidRate)
    case autoServiceWasUpdated(autoServiceWasUpdated: AutoServiceWasUpdated)
    case scheduledAutoService(scheduledAutoService: ScheduledAutoService)
    
    public init?(userInfo: [AnyHashable: Any]) {
        guard let remoteType = RemoteType(rawValue: userInfo["type"] as? String ?? "") else {
            return nil
        }
        switch remoteType {
        case .mechanicRating:
            guard let rating = MechanicRating(userInfo: userInfo) else { return nil }
            self = .mechanicRating(rating: rating)
        case .reminder:
            guard let reminder = MechanicReminder(userInfo: userInfo) else { return nil }
            self = .reminder(reminder: reminder)
        case .userDidRate:
            guard let userDidRate = UserDidRate(userInfo: userInfo) else { return nil }
            self = .userDidRate(userDidRate: userDidRate)
        case .autoServiceUpdated:
            guard let autoServiceUpdated = AutoServiceWasUpdated(userInfo: userInfo) else { return nil }
            self = .autoServiceWasUpdated(autoServiceWasUpdated: autoServiceUpdated)
        case .userScheduledAutoService:
            guard let scheduledAutoService = ScheduledAutoService(userInfo: userInfo) else { return nil }
            self = .scheduledAutoService(scheduledAutoService: scheduledAutoService)
        }
    }
    
    public enum RemoteType: String {
        case reminder = "reminder"
        case mechanicRating = "mechanicRating"
        case userDidRate = "userDidRate"
        case autoServiceUpdated = "autoServiceUpdated"
        case userScheduledAutoService = "userScheduledAutoService"
    }
    
}


public extension RemoteNotification {
    
    struct MechanicReminder {
        
        public init?(userInfo: [AnyHashable: Any]) {
            guard let date = userInfo["date"] as? Date,
                let autoServiceID = userInfo["autoServiceID"] as? String,
                let name = userInfo["name"] as? String else { return nil }
            self.date = date
            self.name = name
            self.autoServiceID = autoServiceID
        }
        
        public let date: Date
        public let name: String
        public let autoServiceID: String
    }
    
}

public extension RemoteNotification {
    
    struct ScheduledAutoService {
        
        public init?(userInfo: [AnyHashable: Any]) {
            guard let autoServiceID = userInfo["autoServiceID"] as? String,
                let userID = userInfo["userID"] as? String else { return nil }
            self.userID = userID
            self.autoServiceID = autoServiceID
        }
        
        public let userID: String
        public let autoServiceID: String
    }
    
}

public extension RemoteNotification {
    
    struct MechanicRating {
        
        public init?(userInfo: [AnyHashable: Any]) {
            guard let mechanicID = userInfo["mechanicID"] as? String,
                let mechanicFirstName = userInfo["mechanicFirstName"] as? String,
                let autoServiceID = userInfo["autoServiceID"] as? String else { return nil}
            self.mechanicID = mechanicID
            self.autoServiceID = autoServiceID
            self.mechanicFirstName = mechanicFirstName
        }
        
        public let mechanicID: String
        public let autoServiceID: String
        public let mechanicFirstName: String
    }
    
}

public extension RemoteNotification {
    
    struct UserDidRate {
        
        public init?(userInfo: [AnyHashable: Any]) {
            guard let userID = userInfo["userID"] as? String,
                let mechanicID = userInfo["mechanicID"] as? String,
                let autoServiceID = userInfo["autoServiceID"] as? String,
                let reviewRating = userInfo["reviewRating"] as? CGFloat else { return nil }
            self.userID = userID
            self.mechanicID = mechanicID
            self.reviewRating = reviewRating
            self.autoServiceID = autoServiceID
        }
        
        public let userID: String
        public let mechanicID: String
        public let reviewRating: CGFloat
        public let autoServiceID: String
    }
    
}

public extension RemoteNotification {
    
    struct AutoServiceWasUpdated {
        
        public init?(userInfo: [AnyHashable: Any]) {
            guard let autoServiceID = userInfo["autoServiceID"] as? String else { return nil }
            self.autoServiceID = autoServiceID
        }
        
        public let autoServiceID: String
    }
    
}

