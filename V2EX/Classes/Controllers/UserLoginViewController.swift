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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("UserLoginViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("UserLoginViewController")
    }
    
    // MARK: private methods
    private func loadOnceCode(completion: (() -> Void)? = nil) {
        SessionService.requestNewSessionFormOnceCode { [weak self] (result) in
            switch result {
            case .Failure(_, let error):
                self?.showError(error)
            case .Success(let code):
                self?.onceCode = code
                completion?()
            }
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
        
        SessionService.performLogin(usernameTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] (result) -> Void in
            self?.hideProgressView()
            
            switch result {
            case .Success(let isLoggedIn):
                if isLoggedIn {
                    self?.showSuccess(status: "登录成功") {
                        self?.dismissSelf()
                    }
                } else {
                    // TODO: Remove the following line
                    self?.showError(status: "用户名或密码错误")
                }
            case .Failure(_, let error):
                self?.showError(error)
            }
        }
        
    }
    
    // MARK: UITextFieldDelegate
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}
