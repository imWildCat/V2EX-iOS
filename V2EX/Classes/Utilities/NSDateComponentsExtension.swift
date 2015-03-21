//
//  NSDateComponentsExtension.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

extension NSDateComponents {
    
    var toSeconds: Int {
        get {
            var returnSeconds = 0
            
            if year != Int.max {
                returnSeconds += year * 31536000
            }
            
            if month != Int.max {
                returnSeconds += month * 2592000
            }
            
            if day != Int.max {
                returnSeconds += day * 86400
            }
            
            if hour != Int.max {
                returnSeconds += hour * 3600
            }
            
            if minute != Int.max {
                returnSeconds += minute * 60
            }
            
            if second != Int.max {
                returnSeconds += second
            }
            
            return returnSeconds
        }
    }
    
}