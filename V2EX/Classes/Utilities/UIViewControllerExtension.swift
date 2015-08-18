//
//  UIViewControllerExtension.swift
//  V2EX
//
//  Created by WildCat on 13/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import KVNProgress

extension UIViewController {
        
    @IBAction func sideMenuButtonTouched(sender: UIBarButtonItem) {
        showSideMenu()
    }
    
    func showSideMenu() {
        RootViewController.displaySideMenu()
    }
    
    // MARK: V2EX
    func showTopicVC(topicID: Int) {
        if let topicVC = storyboard?.instantiateViewControllerWithIdentifier("topicVC") as? TopicViewController {
            topicVC.topicID = topicID
            navigationController?.pushViewController(topicVC, animated: true)
        }
    }
    
    func showUserVC(username: String) {
        if let userVC = storyboard?.instantiateViewControllerWithIdentifier("userVC") as? UserViewController {
            userVC.mode = .OtherUser
            userVC.username = username
            navigationController?.pushViewController(userVC, animated: true)
        }
    }
    
    func showPurchaseVC() {
        if let purchaseVC = storyboard?.instantiateViewControllerWithIdentifier("purchaseVC") as? PurchaseViewController {
            navigationController?.pushViewController(purchaseVC, animated: true)
        }
    }
    
    func showLoginVC() {
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier("userLoginVC") as? UserLoginViewController {
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func showNotificationVC() {
        if let userNotificationVC = storyboard?.instantiateViewControllerWithIdentifier("userNotificationVC") as? UserNotificationViewController {
            navigationController?.pushViewController(userNotificationVC, animated: true)
        }
    }
    
    // Custom UI
    func showLoginAlert() {
        let alert = UIAlertController(title: "您尚未登录", message: "请登录", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "登录", style: UIAlertActionStyle.Default) { [unowned self, alert] (_) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            self.showLoginVC()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { [unowned alert] (_) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Mark: Session
    
    var isLoggedIn: Bool {
        get {
            return checkLogin()
        }
    }
    
    private func checkLogin() -> Bool {
        println( SessionStorage.sharedStorage.isLoggedIn)
        if SessionStorage.sharedStorage.isLoggedIn == true {
            return true
        } else {
            showLoginAlert()
            return false
        }
    }

    // MARK: KVNProgressUI
    
    func showProgressView() {
        KVNProgress.show()
    }
    
    func hideProgressView() {
        KVNProgress.dismiss()
    }
    
    func showSuccess(#status: String, completion: (() -> Void)? = nil) {
        KVNProgress.showSuccessWithStatus(status, completion: completion)
    }
    
    func showSuccess() {
        KVNProgress.showSuccess()
    }
    
    func showError(#status: String, completion: (() -> Void)? = nil) {
        KVNProgress.showErrorWithStatus(status, completion: completion)
    }
    
    func showError(error: NSError?) {
        if let e = error {
            if e.domain == V2EXError.domain, let userInfo = e.userInfo as? [String: String], description = userInfo[NSLocalizedDescriptionKey] {
                if e.code == 401 {
                    showLoginAlert()
                    return
                }
                showError(status: description)
                return
            } else {
                showError(status: "未知错误")
            }
            showError(.Networking)
        }
    }
    
    func showError() {
        KVNProgress.showError()
    }
    
    func showUserLoginVC() {
        if let userLoginVC = storyboard?.instantiateViewControllerWithIdentifier("userLoginVC") as? UserLoginViewController {
            presentViewController(userLoginVC, animated: true, completion: nil)
        }
    }
    
    enum ErrorType {
        case Networking
    }
    
    func showError(type: ErrorType) {
        if type == ErrorType.Networking {
            showError(status: "网络错误，加载失败")
        }
    }
    
    func showProgress(progress: Float, status: String) {
        KVNProgress.showProgress(CGFloat(progress), status: status)
    }
    
    func updateProgress(progress: Float) {
        KVNProgress.updateProgress(CGFloat(progress), animated: true)
    }
    
}
