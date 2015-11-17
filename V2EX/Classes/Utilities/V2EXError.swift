//
//  V2EXError.swift
//  V2EX
//
//  Created by WildCat on 8/11/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

enum V2EXError<T: NSString>: CustomStringConvertible {
    
    case AuthRequired
    case WrongUsernameOrPassword
    case LoginProblem
    case LoginUnknownProblem
    case OtherProblem(T)
    
    static var domain: String {
        return "io.wildcat.V2EX"
    }
    
    internal var errorCode: Int {
        switch self {
        case .AuthRequired:
            return 401
        case .WrongUsernameOrPassword:
            return 1001
        case .LoginProblem:
            return 1002
        case .LoginUnknownProblem:
            return 1009
        case .OtherProblem:
            return 0
        }
    }
    
    var description: String {
        switch self {
        case .AuthRequired:
            return "需要登录"
        case .LoginProblem:
            return "登录有点问题，请重试一次"
        case .LoginUnknownProblem:
            return "未知登录问题，请重试"
        case .WrongUsernameOrPassword:
            return "用户名或密码错误"
        case .OtherProblem(let descriptionObject):
            return String(descriptionObject)
        }
    }
    
    var foundationError: NSError {
        return NSError(domain: self.dynamicType.domain, code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: description
            ])
    }

    
}