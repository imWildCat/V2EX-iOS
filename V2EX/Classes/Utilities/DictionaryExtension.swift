//
//  DictionaryExtension.swift
//  V2EX
//
//  Created by WildCat on 8/26/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(other:Dictionary) {
        for (key,value) in other {
            updateValue(value, forKey:key)
        }
    }
}