//
//  SessionStorage.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

private let _sharedStorage = SessionStorage()

class SessionStorage {
    
    var currentUser: User? = nil {
        didSet {
            lastLogin = NSDate.currentTimestamp()
        }
    }
    
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    
    var lastOnceGot: UInt = 0
    var lastLogin: UInt = 0
    
    
    class var sharedStorage: SessionStorage {
        return _sharedStorage
    }
    
    func shouldRequestNewOnceCode() -> Bool {
        return (NSDate.currentTimestamp() - lastOnceGot) > UInt(500)
    }
    
}

