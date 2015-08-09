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
    func showUserVC(username: String) {
        if let userVC = storyboard?.instantiateViewControllerWithIdentifier("userVC") as? UserViewController {
            userVC.mode = .OtherUser
            userVC.username = username
            self.navigationController?.pushViewController(userVC, animated: true)
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
