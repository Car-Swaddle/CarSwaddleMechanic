//
//  AppDelegate.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 10/5/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CoreData
import Stripe


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLibraries()
        
        _ = pushNotificationController
        
        // TODO: Take this out when things are stable
        store.mainContext.persist()
        
        navigator.setupWindow()
        
        return true
    }
    
    private func setupLibraries() {
        STPPaymentConfiguration.shared.publishableKey = stripePublishableKey
        STPPaymentConfiguration.shared.appleMerchantIdentifier = appleMerchantIdentifier
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationController.didRegister(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        pushNotificationController.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushNotificationController.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return UserActivityHandler.shared.handle(userActivity: userActivity)
    }

}

