//
//  Utils.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

class Utils {
    class func delay(delay: Double, block: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), block)
    }
    
    class func showOrReloadNotificationVC() {
        let rootViewController = containerVC()
        let topVC = rootViewController.viewControllers[0]
        
        if let notificationVC = topVC as? UserNotificationViewController {
            notificationVC.loadData()
        } else {
            topVC.showNotificationVC()
        }
    }
    
    class func containerVC() -> ContainerViewController {
        return UIApplication.sharedApplication().keyWindow!.rootViewController as! ContainerViewController
    }
    
    class func topVC() -> UIViewController {
        return containerVC().viewControllers[0]
    }
    
//    class func readsSessionCookieFromKeyChain() -> Bool {
//        
//    }
}