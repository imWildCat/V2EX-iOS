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
import LNNotificationsUI
import Appirater

// Launch Image: http://tmblr.co/Zof4En1pJwO-D
// From: http://fancycrave.com/post/123814383565/download-by-patrick-fore#notes , July 11, 2015

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if SKPaymentQueue.canMakePayments() {
            
        }
        
        setUpColors()
        
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
        
        func setUpInAppNotification() {
            if let image = UIImage(named: "notification_icon") {
                LNNotificationCenter.defaultCenter().registerApplicationWithIdentifier("v2ex", name: "V2EX", icon: image, defaultSettings: LNNotificationDefaultAppSettings)
            } else {
                NSLog("Cannot found image `notification_icon` to set up LNNotificationCenter")
            }
        }
        
        func setUpAppirater() {
            Appirater.setAppId("1028925704")
            Appirater.setDaysUntilPrompt(3)
            Appirater.setUsesUntilPrompt(5)
            Appirater.setSignificantEventsUntilPrompt(-1)
            Appirater.setTimeBeforeReminding(2)
            Appirater.setDebug(false)
            Appirater.appLaunched(true)
        }
        
        configureKVNProgress()
        configureIQKeyboardManager()
        setUpInAppNotification()
        setUpAppirater()
        NodeService.getAll()
        
        // Background fetch
        let shouldFetch = NSUserDefaults.standardUserDefaults().boolForKey("should_do_background_fetch")
        if shouldFetch {
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        } else {
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
        
        // Notification
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        notification.u
//        println("Received location notification: ", notification)
        let rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootViewController
        let topVC = rootViewController.containerViewController.viewControllers[0]
        
        if let userInfo = notification.userInfo as? [String: String], type = userInfo["type"] {
            print("Userinfo type: \(type)", terminator: "")
            if type == "notification" {
                // TODO: test this:
                Utils.showOrReloadNotificationVC()
            } else if type == "daily_redeem" {
                if let userViewController = topVC as? UserViewController {
                    userViewController.checkDailyTask()
                } else {
                    rootViewController.containerViewController.viewControllers = [rootViewController.containerViewController.userViewController]
                }
            }
        }
    }
    
    private func getCachedUnreadNotificationCount() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("unread_notification_count")
    }
    
    private func getIsDailyTaskNotified() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("is_daily_task_notified")
    }
    
    private func setCachedUnreadNotificationCount(count: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(count, forKey: "unread_notification_count")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func setIsDailyTaskNotified(status: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(status, forKey: "is_daily_task_notified")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        SessionService.getNotificationCount { [weak self] (result) -> Void in
            
            var r: UIBackgroundFetchResult!
            
            if let (count, hasDailyRedeem) = result.value {
                r = UIBackgroundFetchResult.NoData
//                println(count)
//                println(self?.getCachedUnreadNotificationCount())
                if count > 0 && count > self?.getCachedUnreadNotificationCount() ?? 0 {
                    self?.sendUnreadNotificationCountAlert(count)
                    r = UIBackgroundFetchResult.NewData
                }
                if hasDailyRedeem && self?.getIsDailyTaskNotified() == false {
                    self?.sendDailyRedeemAlert()
                    self?.setIsDailyTaskNotified(true) // Avoid duplicate notification
                    r = UIBackgroundFetchResult.NewData
                }
            } else {
                r = UIBackgroundFetchResult.Failed
            }
            
            completionHandler(r)
        }
    }
    
    private func sendUnreadNotificationCountAlert(count: Int) {
        let notification = UILocalNotification()
        let currentTime = NSDate(timeIntervalSinceNow: 1.0)
        notification.userInfo = ["type": "notification"]
        notification.fireDate = currentTime
        notification.alertBody = "您有 \(count) 条未读提醒"
        notification.alertAction = "阅读"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + count
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func sendDailyRedeemAlert() {
        let notification = UILocalNotification()
        let currentTime = NSDate(timeIntervalSinceNow: 5.0)
        notification.userInfo = ["type": "daily_redeem"]
        notification.fireDate = currentTime
        notification.alertBody = "今日登录奖励已可以领取"
        notification.alertAction = "领取"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.timeZone = NSTimeZone.defaultTimeZone()
//        notification.applicationIconBadgeNumber
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func setUpColors() {
        UITextView.appearance().tintColor = UIColor.darkGrayColor()
        UITextField.appearance().tintColor = UIColor.darkGrayColor()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        println("applicationDidBecomeActive")
        setCachedUnreadNotificationCount(0)
        setIsDailyTaskNotified(false)
        
//        println(getCachedUnreadNotificationCount())
//        println(getIsDailyTaskNotified())
        PasteboardWatcher.watch()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        println("applicationWillTerminate")
    }


}

