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
    
    var dismissSelf: (() -> Void)?
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    var lastOnceGot: UInt = 0
    
    // background image is from: https://unsplash.com/photos/5ulmc8IHdLc/download
    // image author: Jonathan Bean
    
    override func viewDidLoad() {
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        loadOnceCode()
    }
    
    // MARK: private methods
    private func loadOnceCode(completion: (() -> Void)? = nil) {
        SessionService.newSessionForm { [weak self](error, onceCode)  in
            self?.onceCode = onceCode
            completion?()
        }
    }

    // MARK: IBActions
    
    @IBAction func closeButtonDidClick(sender: UIButton) {
        dismissSelf?()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginButtonDidClick(sender: UIButton) {
        
        SessionService.performLogin(usernameTextField.text, password: passwordTextField.text) { (error, isLoggedIn) -> Void in
            
        }
        
    }
    
    // MARK: UITextFieldDelegate
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}
