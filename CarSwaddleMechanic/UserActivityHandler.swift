//
//  UserActivityHandler.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 5/23/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation


class UserActivityHandler {
    
    public static let shared: UserActivityHandler = UserActivityHandler()
    
    private init() {}
    
    private let resetPasswordPath = "/reset-password/"
    private let resetTokenQueryItemName = "resetToken"
    
    
    public func handle(userActivity: NSUserActivity) -> Bool {
        print("user activity: \(userActivity)")
        
        guard let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        if let firstQueryItem = components.queryItems?.first, components.path == resetPasswordPath && firstQueryItem.name == resetTokenQueryItemName,
            let resetToken = firstQueryItem.value {
            navigator.showEnterNewPasswordScreen(resetToken: resetToken)
            return true
        } else {
            return false
        }
    }
    
}
