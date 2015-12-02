//
//  TopicFontSize.swift
//  V2EX
//
//  Created by WildCat on 12/1/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

enum TopicFontSize: CustomStringConvertible {
    
    case Normal
    case Small
    case Large
    
    var description: String {
        get {
            switch self {
            case .Small:
                return "小"
            case .Large:
                return "大"
            default:
                return "正常"
            }
        }
    }
    
    var cssClassName: String {
        get {
            switch self {
            case .Small:
                return "small"
            case .Large:
                return "large"
            default:
                return "normal"
            }
        }
    }
    
    init(string: String) {
        switch string {
        case "small":
            self = .Small
        case "large":
            self = .Large
        default:
            self = .Normal
        }
    }
    
}