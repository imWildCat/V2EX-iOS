//
//  UserLoginViewController.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import TSMessages
import OnePasswordExtension

class UserLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var onePasswordButton: UIButton!
    
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    var lastOnceGot: UInt = 0
    
    // background image is from: https://unsplash.com/photos/5ulmc8IHdLc/download
    // image author: Jonathan Bean
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let (username, password) = SessionService.getUsernameAndPassword()
        usernameTextField.text = username
        passwordTextField.text = password
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadOnceCode()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        check1PasswordAvailability()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: private methods
    private func check1PasswordAvailability() {
        if OnePasswordExtension.sharedExtension().isAppExtensionAvailable() == false {
            onePasswordButton.hidden = true
        } else {
            onePasswordButton.hidden = false
        }
    }
    
    private func loadOnceCode(completion: (() -> Void)? = nil) {
        SessionService.requestNewSessionFormOnceCode { [weak self] (result) in
            switch result {
            case .Failure(_, let error):
                self?.showError(error)
            case .Success(let code):
                self?.onceCode = code.0
                completion?()
            }
        }
    }
    
    private func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: IBActions
    
    @IBAction func onePasswordButtonDidClick(sender: UIButton) {
        // Ref: https://github.com/AgileBits/onepassword-app-extension/blob/master/Demos
        OnePasswordExtension.sharedExtension().findLoginForURLString("v2ex.com", forViewController: self, sender: sender) { (loginDictionary, error)in
            if loginDictionary == nil {
                if error!.code != Int(AppExtensionErrorCodeCancelledByUser) {
//                    print("Error invoking 1Password App Extension for find login: \(error)")
                }
                return
            }
            
            self.usernameTextField.text = loginDictionary?[AppExtensionUsernameKey] as? String
            self.passwordTextField.text = loginDictionary?[AppExtensionPasswordKey] as? String
        }
    }
    
    @IBAction func closeButtonDidClick(sender: UIButton) {
        dismissSelf()
    }
    
    @IBAction func loginButtonDidClick(sender: UIButton) {
        
        showProgressView()
        
        SessionService.performLogin(usernameTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] (result) -> Void in
            self?.hideProgressView()
            
            switch result {
            case .Success(let isLoggedIn):
                if isLoggedIn {
                    self?.dismissSelf()
                    TSMessage.showNotificationWithTitle("登录成功", type: .Success)
                } else {
                    // TODO: Remove the following line
                    TSMessage.showNotificationWithTitle("用户名或密码错误", type: .Error)
                }
            case .Failure(_, let error):
                self?.showHUDError(error)
            }
        }
        
    }
    
    // MARK: Show or hide title container
    func showTitleContainer() {
        UIView.animateWithDuration(0.15, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.titleContainer.alpha = 1
            }, completion: nil)
    }
    
    func hideTitleContainer() {
        UIView.animateWithDuration(0.15, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.titleContainer.alpha = 0
            }, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideTitleContainer()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        showTitleContainer()
    }
    

}
