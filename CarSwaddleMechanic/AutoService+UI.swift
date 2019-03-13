//
//  AutoService+UI.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 3/11/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Store


extension AutoService.Status {
    
    var color: UIColor {
        switch self {
        case .scheduled:
            return .scheduledColor
        case .inProgress:
            return .inProgressColor
        case .completed:
            return .completedColor
        case .canceled:
            return .canceledColor
        }
    }
    
    var nextStatus: AutoService.Status? {
        switch self {
        case .scheduled:
            return .inProgress
        case .inProgress:
            return .completed
        case .completed:
            return nil
        case .canceled:
            return nil
        }
    }
    
}
