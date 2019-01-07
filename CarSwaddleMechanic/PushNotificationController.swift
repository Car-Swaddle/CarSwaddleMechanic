//
//  PushNotificationController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/8/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UserNotifications
import UIKit
import CarSwaddleData


public let pushNotificationController = PushNotificationController()

public class PushNotificationController: NSObject {
    
    private let mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func didRegister(withDeviceToken deviceToken: Data) {
        let deviceToken = self.deviceTokenString(fromDeviceTokenData: deviceToken)
        store.privateContext { [weak self] context in
            self?.mechanicNetwork.update(isActive: nil, token: deviceToken, dateOfBirth: nil, address: nil, in: context) { mechanicObjectID, error in
                print("mechanic updated")
            }
        }
    }
    
    public func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("Failed to register remote notifications: \(error)")
    }
    
    public func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("got remote notification: \(userInfo)")
        completionHandler(.newData)
    }
    
    public func requestPermission() {
        let options: UNAuthorizationOptions = [.badge, .alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if error == nil && granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func deviceTokenString(fromDeviceTokenData data: Data) -> String {
        return data.reduce("", {$0 + String(format: "%02X", $1)})
    }
    
}

extension PushNotificationController: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("open settings for")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive response")
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present")
        completionHandler([.alert, .badge, .sound])
    }
    
}
