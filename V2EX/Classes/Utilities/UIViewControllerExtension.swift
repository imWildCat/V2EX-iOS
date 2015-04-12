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
        RootViewController.displaySideMenu()
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
    
}
