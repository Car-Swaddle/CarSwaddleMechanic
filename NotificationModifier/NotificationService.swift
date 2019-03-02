//
//  NotificationService.swift
//  NotificationModifier
//
//  Created by Kyle Kendall on 3/2/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import UserNotifications

let serverDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
}()

let localDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd HH:mm z"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter
}()

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = bestAttemptContent?.userInfo ?? [:]
        
        if let bestAttemptContent = bestAttemptContent, (userInfo["type"] as? String) == "reminder",
            let dateString = userInfo["date"] as? String,
            let name = userInfo["name"] as? String,
            let date = serverDateFormatter.date(from: dateString) {
            
            let localFormattedDate = localDateFormatter.string(from: date)
            let formatString = NSLocalizedString("%@, you have an oil change coming up: %@", comment: "Push body")
            let body = String(format: formatString, name, localFormattedDate)
            bestAttemptContent.body = body
            contentHandler(bestAttemptContent)
        } else {
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
