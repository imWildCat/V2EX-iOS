//
//  SessionStorage.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

//private let _sharedStorage = SessionStorage()

class SessionStorage {
    
    private static let _sharedStorage = SessionStorage()
    
    var currentUser: User? = nil {
        didSet(newValue) {
            if newValue != nil {
                lastLogin = NSDate.currentTimestamp()
            }
            lastLogin = 0
        }
    }
    
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    
    var lastOnceGot: UInt = 0
    var lastLogin: UInt = 0
    
    var isLoggedIn: Bool {
        get {
            return currentUser != nil
        }
    }
    
    
    class var sharedStorage: SessionStorage {
        return _sharedStorage
    }
    
    func shouldRequestNewOnceCode() -> Bool {
        return (NSDate.currentTimestamp() - lastOnceGot) > UInt(500)
    }
    
    func logOut() {
        currentUser = nil
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in cookieStorage.cookies as! [NSHTTPCookie] {
            cookieStorage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        SessionService.clearUsernameAndPassword()
    }
    
}

