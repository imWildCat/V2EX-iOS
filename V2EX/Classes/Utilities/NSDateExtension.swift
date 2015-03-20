//
//  NSDateExtension.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

extension NSDate {
    class func currentTimestamp() -> UInt {
        return UInt(NSDate().timeIntervalSince1970)
    }
}