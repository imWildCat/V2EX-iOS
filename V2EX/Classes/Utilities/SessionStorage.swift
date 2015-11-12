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
                return
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
    
    var shouldCheckLoginAsync: Bool {
        get {
            if NSDate.currentTimestamp() - lastLogin > 43200 {
                return true
            }
            return false
        }
    }
    
    
    class var sharedStorage: SessionStorage {
        return _sharedStorage
    }
    
    func shouldRequestNewOnceCode() -> Bool {
        return (NSDate.currentTimestamp() - lastOnceGot) > UInt(500)
    }
    
}

