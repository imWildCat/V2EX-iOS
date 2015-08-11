//
//  V2EXError.swift
//  V2EX
//
//  Created by WildCat on 8/11/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

enum V2EXError: Printable {
    
    case AuthRequired
    
    static var domain: String {
        return "io.wildcat.V2EX"
    }
    
    internal var errorCode: Int {
        switch self {
        case .AuthRequired:
            return 401
        }
    }
    
    var description: String {
        switch self {
        case .AuthRequired:
            return "需要登录"
        }
    }
    
    var foundationError: NSError {
        return NSError(domain: self.dynamicType.domain, code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: description
            ])
    }

    
}