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
    
    var onceCode: String = "" {
        didSet {
            lastOnceGot = NSDate.currentTimestamp()
        }
    }
    var lastOnceGot: UInt = 0
    
    
    class var sharedStorage: SessionStorage {
        return _sharedStorage
    }
    
}

