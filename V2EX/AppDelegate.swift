//
//  AppDelegate.swift
//  V2EX
//
//  Created by WildCat on 12/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import StoreKit
import KVNProgress
import IQKeyboardManager

// Launch Image: http://tmblr.co/Zof4En1pJwO-D
// From: http://fancycrave.com/post/123814383565/download-by-patrick-fore#notes , July 11, 2015

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if SKPaymentQueue.canMakePayments() {
            
        }
        
        func configureKVNProgress() {
            let configuration = KVNProgressConfiguration()
            
//            configuration.statusColor = UIColor.darkGrayColor()
//            configuration.statusFont = UIFont.systemFontOfSize(17.0)
//            configuration.circleStrokeForegroundColor = UIColor.darkGrayColor()
//            configuration.circleStrokeBackgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.3)
//            configuration.backgroundFillColor = UIColor(white: 0.9, alpha: 0.9)
//            configuration.backgroundTintColor = UIColor.whiteColor()
//            configuration.successColor = UIColor.darkGrayColor()
//            configuration.errorColor = UIColor.darkGrayColor()
//            configuration.circleSize = 75.0
//            configuration.lineWidth = 2.0
            configuration.fullScreen = false
            configuration.minimumSuccessDisplayTime = 0.6
            configuration.minimumErrorDisplayTime = 1.2
//            configuration.allowUserInteraction = true
            configuration.tapBlock = { (progressView) in
                KVNProgress.dismiss()
            }
            
            KVNProgress.setConfiguration(configuration)
        }
        
        func configureIQKeyboardManager() {
            IQKeyboardManager.sharedManager().disableInViewControllerClass(CreateTopicViewController)
            IQKeyboardManager.sharedManager().disableInViewControllerClass(ReplyTopicViewController)
            IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 200.0
            // TODO: Distance only configure for LoginVC
        }
        
        configureKVNProgress()
        configureIQKeyboardManager()
        NodeService.getAll()
        
        // Background fetch
        let shouldFetch = NSUserDefaults.standardUserDefaults().boolForKey("should_do_background_fetch")
        if shouldFetch {
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        } else {
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
        
        // Notification
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert |
            UIUserNotificationType.Badge |
            UIUserNotificationType.Sound, categories: nil))
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        println("Received location notification: ", notification)
        let rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootViewController
        if let topVC = rootViewController.containerViewController.viewControllers[0] as? UIViewController {
            topVC.showNotificationVC()
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        SessionService.getNotificationCount { (error, count) -> Void in
            if count > 0 {
                let notification = UILocalNotification()
                let currentTime = NSDate(timeIntervalSinceNow: 2.0)
                notification.fireDate = currentTime
                notification.alertBody = "您有 \(count) 条未读提醒"
                notification.alertAction = "阅读"
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + count
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            
            let r = UIBackgroundFetchResult.NewData
            completionHandler(r)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

