//
//  UserLoginViewController.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    var lastOnceGot: UInt = 0
    
    // background image is from: https://unsplash.com/photos/5ulmc8IHdLc/download
    // image author: Jonathan Bean
    
    override func viewDidLoad() {
        let (username, password) = SessionService.getUsernameAndPassword()
        usernameTextField.text = username
        passwordTextField.text = password
        
    }
    
    override func viewDidAppear(animated: Bool) {
        loadOnceCode()
    }
    
    // MARK: private methods
    private func loadOnceCode(completion: (() -> Void)? = nil) {
        SessionService.requestNewSessionFormOnceCode { [weak self](error, onceCode)  in
            self?.onceCode = onceCode
            completion?()
        }
    }
    
    private func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: IBActions
    
    @IBAction func closeButtonDidClick(sender: UIButton) {
        dismissSelf()
    }
    
    @IBAction func loginButtonDidClick(sender: UIButton) {
        
        showProgressView()
        
        SessionService.performLogin(usernameTextField.text, password: passwordTextField.text) { [weak self](error, isLoggedIn) -> Void in
            
            if isLoggedIn {
                self?.showSuccess(status: "登录成功") {
                    self?.dismissSelf()
                    return
                }
                
            } else if error != nil {
                self?.showError(status: "登录失败，网络错误")
            } else {
                self?.showError(status: "登录失败，用户名或密码错误")
            }
        }
        
    }
    
    // MARK: UITextFieldDelegate
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}
